
--[[    
Module for finding a determinant. Currently only wotks when given a 3x3 matrix.
--]]

local inspect = require "inspect"
--The table that acts as module to return at end of file.
local detFinder = {}

--Prints submatrices table. Which has the form: {{{2, 2}, {3, 3}}, {{4, 4}, {5, 5}}, ...}
function detFinder.printMatrix(matrix)
    local outputString = ""
    --Goes through each row
    for i = 1, #matrix, 1 do
        for j = 1, #matrix[i], 1 do
            outputString = outputString .. "Row " .. j .. ":"
            --Inner goes through each column
            for k, v in pairs(matrix[i][j]) do

                --print("row ".. i .. "  Value " .. v)
                outputString = outputString .. " " .. v .. " "
            end
            --print(matrix[i])
            outputString = outputString .. "\n"
        end
        outputString = outputString .. "\n"
    end

    print(outputString)
end

--[[
Splits a 3x3 matrix into 3 2x2 matrices(according to rules of cofactor expansion). It "skips" one column at the time.
Using tail-call recursion here, and when base case is reached simply return the 3 matrices table that is "submatrices". 
--]]
function detFinder.split(matrix, submatrices, columnsCount)

    --printMatrix(matrix)
    if columnsCount == 0 then
        return submatrices
    end

    local matrix2x2 = {{}, {}}
    for i = 2, #matrix, 1 do
        --print("Goint through row: " .. i)
        --print("Size of subtable: " .. #matrix[1])
        for v = 1, #matrix[i], 1 do
            --print("Going through column: " .. v)
            if v ~= columnsCount then
                --print("Adding value at " .. " i: " .. i .. " v: " .. v .. "  value: " .. tostring(matrix[i][v]))
                table.insert(matrix2x2[i-1], matrix[i][v])    
            end
        end
    end

    table.insert(submatrices, matrix2x2)

    return detFinder.split(matrix, submatrices, columnsCount-1)

end

--[[
Should split a matrix with dimension N into N submatrices.
Where the first row is ommitted since expansion takes plas across there.

]]
function detFinder.split2(matrix, subMatrices, N, skipColumn)
    --base case
    if (skipColumn == 0) then
        return subMatrices
    end

    local reverseIndex = N - (skipColumn - 1)
    local subMatrix = {}

    for i = 2, N, 1 do
        local row = {}
        for v = 1, N, 1 do
            if (v ~= reverseIndex) then
                table.insert(row, matrix[i][v])
            end
        end
        table.insert(subMatrix, row)
    end


    table.insert(subMatrices, subMatrix)

    return detFinder.split2(matrix, subMatrices, N, skipColumn-1)

end


function detFinder.calculateDet3X3(matrix)

    local a = matrix[1][1]
    local b = matrix[1][2]
    local c = matrix[1][3]
    local abc = {}

    for i = 1, 3, 1 do
        table.insert(abc, matrix[1][i])
    end

    local Det3x3 = 0

    --print("a: " .. a .. " b: " .. b .. " c: " .. c)

    local subMatrices = detFinder.split2(matrix, {}, 3, 3)
    --Need to reverse the submatrixes to have them in the right order for the calculations
    --local subMatrices = detFinder.reverseTable(subMatrices)
    --detFinder.printMatrix(subMatrices)

    local plusMinus = 0
    for key, value in pairs(subMatrices) do
        print("key: " .. key)
        print("value: " .. tostring(value))
        local subMatrix = value
        local scalar = abc[key]
        local subMatrixDet = detFinder.calculateDet2X2(subMatrix)
        print("SubmatrixDet: " .. subMatrixDet)

        --plusMinus. If modulo equals 0 then apply plus, if 1 apply minus.
        if (plusMinus % 2 == 0) then
            Det3x3 = Det3x3 + (scalar * subMatrixDet)
        else
            Det3x3 = Det3x3 - (scalar * subMatrixDet)
        end

        plusMinus = plusMinus + 1

        print("Current value of determinant: " .. Det3x3)
    end

    print("Det of 3x3 matrix: " .. Det3x3)

    return Det3x3

end



--[[
The main entry function into calculating the determinant.
    input - is a square matrix, represented in a Lua table.
    {{row1}, {row2}, ... , {rowN}}
]]
function detFinder.calculateDet(matrix, N)

    local finalDetValue = 0
    local recDepth = 1

    local function innerDet(matrix, N)
        --print("Recursion depth atm: " .. recDepth)
        
        if (N == 2) then
            print("Entering calc2X2Det with: " .. inspect(matrix))
            return detFinder.calculateDet2X2(matrix)
        end

        --print("Matrix is a: " .. N .. "x" .. N)

        --local N = #matrix
        local firstRow = {}
        for i = 1, N, 1 do
            table.insert(firstRow, matrix[1][i])
        end
        --print("First row: " .. inspect(firstRow))


        local ss = detFinder.split2(matrix, {}, N, N)
        --print("ss size: " .. #ss)
        --print(inspect(ss))
        
        recDepth = recDepth + 1
        --N = N - 1
        print("finalDetValue atm: " .. finalDetValue)

        for v = 1, N, 1 do
            
            if (v % 2 == 0) then
                --print("Minus - Entering with " .. -firstRow[v] .. "*" .. detValue)
                finalDetValue = finalDetValue - (firstRow[v] * innerDet(ss[v], N-1))
                --detValue = detValue * (-firstRow[v])
                --innerDet(ss[v], N-1, detValue, -firstRow[v])
            else
                --print("Plus - Entering with " .. firstRow[v] .. "*" .. detValue)
                finalDetValue = finalDetValue + (firstRow[v] * innerDet(ss[v], N-1))
                --detValue = detValue * (firstRow[v])
                --innerDet(ss[v], N-1, detValue, firstRow[v])
            end
        end
        
        print("Does it ever reach here^^^^")
        return finalDetValue
    end

    finalDetValue = innerDet(matrix, N)

    return finalDetValue

end


function detFinder.calculateDet2(matrix, N)

    local detValue = 0
    --local recDepth = 0
    local plusMinus = 1
    local dString = ""

    local function innerDet(matrix, N, recDepth)
        
        local firstRow = {}
        for i = 1, N, 1 do
            if (i % 2 == 0) then
                table.insert(firstRow, -matrix[1][i])
            else
                table.insert(firstRow, matrix[1][i])
            end
        end
        
        --for m = 1, recDepth, 1 do
            --dString = dString .. "*"
        --end

        local subMatrices = detFinder.split2(matrix, {}, N, N)
        print("First row: " .. inspect(firstRow))
        if (N == 2) then
            print("Entering calc2X2Det with: " .. inspect(matrix))
            local det2x2Val = detFinder.calculateDet2X2(matrix)
            dString = dString .. "Last " .. det2x2Val
            print(dString)
            print("finalDetValue: " .. detValue)
            dString = ""
            return det2x2Val
        else
            for v = 1, #subMatrices, 1 do
                print(v)
                --recDepth = recDepth + 1
                --if (v % 2 == 0) then
                    print(firstRow[v] .. "* innerDet(...)")
                    dString = dString .. firstRow[v] .. " -> "
                    detValue = detValue + (firstRow[v] * innerDet(subMatrices[v], N-1, recDepth + 1))
                    
                    --return (firstRow[v] * innerDet(subMatrices[v], N-1))
                --else
                    --detValue = detValue + (firstRow[v] * innerDet(subMatrices[v], N-1))
                    --print(firstRow[v] .. "* innerDet(...)")
                    --dString = dString .. firstRow[v] .. " | "
                --end
            end
        end

        --print(dString)
        return detValue
    end

    local finalDetValue = innerDet(matrix, N, 1)

    return finalDetValue

end


function detFinder.calculateDet3(matrix, N)

    

    --Shoulld contain the 2x2 dets, eg associated scalar * det of the 2x2 matrix
    --local subDets = {}

    local function innerDet(matrix, N, sd, cofactors)

        if (N == 2) then
            return detFinder.calculateDet2X2(matrix)
        end

        local firstRow = {}
        for i = 1, N, 1 do
            if (i % 2 == 0) then
                table.insert(firstRow, -matrix[1][i])
            else
                table.insert(firstRow, matrix[1][i])
            end
        end

        print(inspect(firstRow))

        --detValue = scalar * detValue

        local subMatrices = detFinder.split2(matrix, {}, N, N)

        for i = 1, #subMatrices, 1 do
            local subMatrix = subMatrices[i]
            table.insert(cofactors, firstRow[i])
            local subDet = innerDet(subMatrix, N-1, sd, cofactors)
            --print(subDet)
            if (type(subDet) == "number") then
                table.insert(sd, subDet)
            end
            
        end


        return sd, cofactors
        
    end

    local det2x2, cofactors = innerDet(matrix, N, {}, {})
    print(inspect(det2x2))
    print(inspect(cofactors))

    local detValue = 0
    --Tells the depth of how many cofactors that should not be 
    --directly applied to the result of a Det of a 2x2 matrix.
    local outsideCofactorDepth = N - 3
    local cofactorSize = #cofactors

    local function cofactorMult(cofactors, det2x2, N, counter, ddd, ds)
        if (#cofactors == 0 or #det2x2 == 0) then
            print("empty...")
            print(ddd)
            return ddd, ds
        end

        if (counter <= outsideCofactorDepth) then
            print("running outside cofactor")
            local outsideCofactor = table.remove(cofactors, 1)
            ds = ds .. outsideCofactor .. "*" .. ddd
            return cofactorMult(cofactors, det2x2, N, counter + 1, outsideCofactor * ddd, ds)
        end

        print("sdsdsdsdsd")
        ds = ds .. "("
        for i = counter, counter+2, 1 do
            print("cofactors: " .. #cofactors .. " det2x2: " .. #det2x2)
            local det2x2Value = table.remove(det2x2, 1)
            local cofactorValue = table.remove(cofactors, 1)
            ds = ds .. "+ " .. cofactorValue .. "*" .. det2x2Value
            ddd = ddd + (cofactorValue * det2x2Value)
        end
        ds = ds .. ")"
       
        return cofactorMult(cofactors, det2x2, N, 1, ddd, ds)
    end

    local finalDetValue, debugString = cofactorMult(cofactors, det2x2, N, 1, 1, "")
    print(debugString)
    print(finalDetValue)

end


function printMatrix2(matrix, N)
    local matrixString = ""

    for i = 1, N, 1 do
        matrixString = matrixString .. "\n"
        matrixString = matrixString .. "Row " .. i .. ": "
        for v = 1, N, 1 do
            matrixString = matrixString .. matrix[i][v] .. "  "
        end
    end

    return matrixString

end

function detFinder.reverseTable(t)

    local reversedTable = {}
    --print("Size of table: " .. #t)
    for i = #t, 1, -1 do
        print(t[i])
        table.insert(reversedTable, t[i])
    end

    return reversedTable

end


--[[
Accepts only a 2d array with inner nember containing 2 number each, 4 numbers in total

Example: dummy2x2 = {{5, 2}, {9, 7}}

returns a number. Which is the determinant of a submatrix.

--]]
function detFinder.calculateDet2X2(matrix2x2)

    if (#matrix2x2[1] ~= 2 or #matrix2x2[2] ~= 2 ) then
        error("Malformed 2x2 matrix")
    end

    local ad = matrix2x2[1][1] * matrix2x2[2][2]
    local bc = matrix2x2[1][2] * matrix2x2[2][1]

    local det = ad - bc

    --printMatrix(matrix2x2)
    --print("ad = " .. ad)
    --print("bc = " .. bc)
    print("Det of matrix is: " .. det)

    return det

end

return detFinder