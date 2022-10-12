--[[
Script Exchange is a value added initiative through which customers can
upload or download scripts that help simplify their processes and reduce the effort of repetitive work.

THE SCRIPT EXCHANGE IS PROVIDED ON AN "AS-IS" BASIS. USE OF THE SCRIPTS AND
RELIANCE ON ANY
RESULTS DERIVED THEREFROM IS SOLELY AND STRICTLY AT THE USER'S DISCRETION.
ALTAIR MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EXPRESS OR
IMPLIED, AND EXPRESSLY
DISCLAIMS THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE.
ALTAIR DOES NOT WARRANT THE OPERATION, ACCURACY, CORRECTNESS OR
COMPLETENESS OF THE SCRIPTS
OR ANY RESULTS DERIVED THEREFROM.
--]]

--Fourier Transform Helper
require 'utils.complex_helper'

function IFFT2D(m) --O(n^2 log n )
    local nx = m.RowCount
    local ny = m.ColumnCount
    
    local out = m*1
    
    for jx=1,nx do
        out:ReplaceSubMatrix(out:SubMatrix(jx,jx,1,ny):IFFT(), jx, 1)
    end
    
    out = out:Transpose()
    
    for jy=1,ny do
        out:ReplaceSubMatrix(out:SubMatrix(jy,jy,1,nx):IFFT(), jy, 1)
    end
    
    out = out:Transpose()
    
    return out
end

function FFT2D(m) --O(n^2 log n )
    local nx = m.RowCount
    local ny = m.ColumnCount
    local out = m*1
    
    for jx=1,nx do
        out:ReplaceSubMatrix(out:SubMatrix(jx,jx,1,ny):FFT(), jx, 1)
    end
    
    out = out:Transpose()
    
    for jy=1,ny do
        out:ReplaceSubMatrix(out:SubMatrix(jy,jy,1,nx):FFT(), jy, 1)
    end
    
    out = out:Transpose()
    
    return out
end 

--Used for testing to slow to actually use (unoptimized), O(n^4)
--Should be normalized to 1/nm after use
function DFT2D(m)
    nx = m.RowCount
    ny = m.ColumnCount
    out = pf.ComplexMatrix.New(nx, ny, 0*j)
    for kx=0,nx-1 do
        for ky=0,ny-1 do
            for jx=0,nx-1 do
                for jy=0,ny-1 do
                    out[kx+1][ky+1] = out[kx+1][ky+1] + complex.exp(-i*2*pf.Const.pi*(kx*jx/nx + ky*jy/ny))*m[jx+1][jy+1]
                end
            end
        end
    end  
    return out     
end

function IDFT2D(m)
    local nx = m.RowCount
    local ny = m.ColumnCount
    local out = pf.ComplexMatrix.New(nx, ny, 0*j)
    for kx=0,nx-1 do
        for ky=0,ny-1 do
            for jx=0,nx-1 do
                for jy=0,ny-1 do
                    out[jx+1][jy+1] = out[jx+1][jy+1] + complex.exp(i*2*pf.Const.pi*(kx*jx/nx + ky*jy/ny))*m[kx+1][ky+1]
                end
            end
        end
    end  
    return out     
end
