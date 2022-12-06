const expectedAtField = document.querySelector("form input[name='task[expected_at]']")
const ownerField = document.querySelector("form select[name='task[owner_id]']")
const pointEstimateField = document.querySelector("form input[name='task[point_estimate]']")
const setRequiredAttribute = (target) => {
  expectedAtField.required = ownerField.required = pointEstimateField.required = !!target.value
}

const startedAtField = document.querySelector("form input[name='task[started_at]']")
document.addEventListener("DOMContentLoaded", () => setRequiredAttribute(startedAtField))
startedAtField.addEventListener("change", (e) => setRequiredAttribute(e.target))
