local js = require "js"

--js.global:alert("hello")
local window = js.global
local document = window.document


print("titles is: " .. document.title)
--for i = 1, 10, 1 do
    --Window:alert("Hello " .. i)
--end

--Window:prompt("cc", "Empty")

local findDeterminantButton =  document:getElementById("submit-matrix")


findDeterminantButton:addEventListener("click", 

function (event)
    --print("Submitted")
    --print(document:getElementById("11").value)
    local matrix = {{}, {}, {}}
    matrixElements = document:querySelectorAll("input[type=number]")
    --print(matrixElements[0].value)

    local rowIndex = 0

    local isValidMatrix = validateMatrixForm(matrixElements)

    if (isValidMatrix ~= true) then
        window:alert("Not a valid matrix. Be sure to fill in every value")
        return
    end

    
    for i = 0, #matrixElements - 1, 1 do
        if i % 3 == 0 then
            rowIndex = rowIndex + 1
        end
        --print(matrixElements[i].value)
        --print("RowIndex: " .. rowIndex)
        table.insert(matrix[rowIndex], tonumber(matrixElements[i].value))
    end

    finalDet = calculateDet3X3(matrix)
    
    detOutputElement = createVisualOutput(finalDet)

    formElement = document:getElementsByTagName("form")[0]

    --Neat little function: element.after() - Appends an element after the form Element(in this case)
    formElement:after(detOutputElement)
    
end
)

--[[    
A 3x3 matrix gets broken down into 3 submatrixes. Her I am doing expansion across the first row.
The 2x2 submatrixes are 3 where each has 1 column "removed".

--]]

--Prints submatrices table. Which has the form: {{{2, 2}, {3, 3}}, {{4, 4}, {5, 5}}, ...}
function printMatrix(matrix)
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
function split(matrix, submatrices, columnsCount)

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

    return split(matrix, submatrices, columnsCount-1)

end


function calculateDet3X3(matrix)

    local a = matrix[1][1]
    local b = matrix[1][2]
    local c = matrix[1][3]
    local abc = {matrix[1][1], matrix[1][2], matrix[1][3]}
    local Det3x3 = 0

    print("a: " .. a .. " b: " .. b .. " c: " .. c)

    local subMatrices = split(matrix, {}, 3)
    --Need to reverse the submatrixes to have them in the right order for the calculations
    local subMatrices = reverseTable(subMatrices)
    printMatrix(subMatrices)

    local plusMinus = 0
    for key, value in pairs(subMatrices) do
        print("key: " .. key)
        print("value: " .. tostring(value))
        local subMatrix = value
        local scalar = abc[key]
        local subMatrixDet = calculateDet2X2(subMatrix)
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

function reverseTable(t)

    local reversedTable = {}
    --print("Size of table: " .. #t)
    for i = #t, 1, -1 do
        --print(t[i])
        table.insert(reversedTable, t[i])
    end

    return reversedTable

end


--[[
Accepts only a 2d array with inner nember containing 2 number each, 4 numbers in total

Example: dummy2x2 = {{5, 2}, {9, 7}}

returns a number. Which is the determinant of a submatrix.

--]]
function calculateDet2X2(matrix2x2)

    if (#matrix2x2[1] ~= 2 or #matrix2x2[1] ~= 2 ) then
        error("Malformed 2x2 matrix")
    end

    ad = matrix2x2[1][1] * matrix2x2[2][2]
    bc = matrix2x2[1][2] * matrix2x2[2][1]

    det = ad - bc

    --printMatrix(matrix2x2)
    print("ad = " .. ad)
    print("bc = " .. bc)
    print("Det of matrix is: " .. det)

    return det

end


--Validates that all fields in the matrix has a number in it(eg: Its not empty)
function validateMatrixForm(matrixElements) 

    for i = 0, #matrixElements - 1, 1 do
        local checkValue = matrixElements[i].value
        if checkValue == "" then
            return false
        end
    end

    return true

end

--[[
Creates an element to be injected into webpage when determinant has
been successfully calculated.

input: Number Determinant
output: HTML Element

--]]

function createVisualOutput(Determinant)

    --Removes the previous-old determinant if it exists from the DOM.
    local previousElement = document:getElementsByTagName("h2")
    if (previousElement.length ~= 0.0) then
        previousElement[0]:remove()
    end

    local h2 = document:createElement("h2")
    h2.textContent = "Determinant is: " .. tostring(Determinant)

    return h2

end


