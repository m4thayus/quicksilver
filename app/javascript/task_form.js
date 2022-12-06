const expectedAtField = document.querySelector("form input[name='task[expected_at]']")
const pointEstimateField = document.querySelector("form input[name='task[point_estimate]']")
const setRequiredAttribute = (target) => {
  const toggle = !!target.value
  expectedAtField.required = toggle
  pointEstimateField.required = toggle
}

const startedAtField = document.querySelector("form input[name='task[started_at]']")
document.addEventListener("DOMContentLoaded", () => setRequiredAttribute(startedAtField))
startedAtField.addEventListener("change", (e) => setRequiredAttribute(e.target))
