--[[

Script.lua -> Should mainly contain functionality realted to the webpage representation.
detFinder.lua -> Contains only the functionality for finding a determinant with a pure lua table

--]]


local js = require "js"
local window = js.global
local document = window.document

--Determinant finder module
local detFinder = require("detFinder")

print(detFinder["split"])
--for i = 1, 10, 1 do
    --Window:alert("Hello " .. i)
--end

--Window:prompt("cc", "Empty")


--Global buttons on page
local findDeterminantButton =  document:getElementById("submit-matrix")
local randomizeButton = document:getElementById("randomize")
local generateMatrixButton = document:getElementById("createMatrixButton")
--Form element (empty in the beginning)
local formElement = document:getElementsByTagName("form")[0]


generateMatrixButton:addEventListener("click", 

function (event)

    print("generate matrix bb")

    local dimensionsNumber = tonumber(document:getElementById("dimensionsInput").value)
    local numberOfCells = dimensionsNumber * dimensionsNumber
    --By setting the max-width property here, I dont need break tags insert anymore to
    --maintain a well formed matrix
    local matrixCellWidth = 55

    local matrixDivElement = document:getElementById("matrixDiv")
    matrixDivElement.style.maxWidth = tostring(matrixCellWidth * dimensionsNumber) .. "px"

    for i = 0, numberOfCells-1, 1 do
        local inputElement = document:createElement("input")
        inputElement.type = "number"
        inputElement.className = "matrixCell"
        matrixDivElement:appendChild(inputElement)
       
    end

    findDeterminantButton:removeAttribute("hidden");
    randomizeButton:removeAttribute("hidden");

end


)

findDeterminantButton:addEventListener("click", 

function (event)
    --print("Submitted")
    --print(document:getElementById("11").value)
    local matrix = {{}, {}, {}}
    local matrixElements = document:querySelectorAll(".matrixCell")
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

    local finalDet = detFinder.calculateDet3X3(matrix)
    
    local detOutputElement = createVisualOutput(finalDet)

    --Neat little function: element.after() - Appends an element after the form Element(in this case)
    formElement:after(detOutputElement)
    
end
)

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


randomizeButton:addEventListener("click", 

function (event)
    randomizeAllValues(-15, 15)
end

)

--Inserts into all fields of the matrix some random values.
--input: 2 Integers, first is lowest bound, second is highest bound
function randomizeAllValues(lowerBound, higherBound)

    --All input fields in the matrix
    local matrixElements = document:querySelectorAll(".matrixCell")

    for key, value in pairs(matrixElements) do
        value.value = math.random(lowerBound, higherBound)
    end
end


