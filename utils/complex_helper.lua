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
--complex helper
function complex.exp(z)
    return math.exp(z.re) * ( math.cos(z.im) + j*math.sin(z.im) )
end

function complex.sin(z)
    return 0.5*i*(complex.exp(-j*z) - complex.exp(j*z))
end

function complex.cos(z)
    return 0.5*(complex.exp(-j*z) + complex.exp(j*z))
end

function complex.tan(z)
    return complex.sin(z) / complex.cos(z)
end

function complex.atan(z)
    return -j/2 * complex.log( (1+j*z) / (1-j*z) )
end

function complex.asin(z)
    return -j * complex.log(i*z + complex.Abs(1-z^2)^0.5 * complex.exp(i/2 * pf.Complex.Angle(1-z^2))) 
end

function complex.acos(z)
    return -j * complex.log(z + i*complex.Abs(1-z^2)^0.5 * complex.exp(i/2 * pf.Complex.Angle(1-z^2)))
end

function complex.sinh(z)
    return j*complex.sin(z/j)
end

function complex.cosh(z)
    return complex.cos(z/j)
end

function complex.sqrt(z)
    return z^0.5
end

function complex.pow(z,p)
    return z^p
end

function complex.log(z)
    return math.log(z:Abs()) + i*z:Angle()
end

function complex.log10(z)
    return complex.log(z) / math.log(10)
end

function complex.conj(c)
    return c.re - j*c.im
end

--Set Existing functions to match math functions
complex.abs = pf.Complex.Abs
