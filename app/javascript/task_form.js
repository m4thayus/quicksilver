const expectedAtField = document.querySelector("form input[name='task[expected_at]']")
const ownerField = document.querySelector("form select[name='task[owner_id]']")
const pointEstimateField = document.querySelector("form input[name='task[point_estimate]']")
const boardField = document.querySelector("form select[name='task[board_id]']")

const isBizDevTask = () => Array.from(boardField.querySelectorAll("option")).find(option => option.selected)?.textContent === "bizdev"

const setRequiredAttribute = (target) => {
  const present = !!target.value
  expectedAtField.required = ownerField.required = present
  if (isBizDevTask()) return

  pointEstimateField.required = present
}

const pointsField = document.querySelector("form input[name='task[points]']")
const pointsOutput = document.querySelector("form output")
const setOutput = () => pointsOutput.textContent = (pointEstimateField.value || 0) - (pointsField.value || 0)
pointsField.addEventListener("input", setOutput)
pointEstimateField.addEventListener("input", setOutput)

const startedAtField = document.querySelector("form input[name='task[started_at]']")
document.addEventListener("DOMContentLoaded", () => {
  setRequiredAttribute(startedAtField)
  setOutput()
})
startedAtField.addEventListener("change", (e) => setRequiredAttribute(e.target))
