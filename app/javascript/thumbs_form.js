const SESSION_STORAGE_KEY = "approved-tasks"
const getApprovedTasks = () => JSON.parse(sessionStorage.getItem(SESSION_STORAGE_KEY)) ?? []
const setApprovedTasks = (tasks) => {
  if (tasks.length > 0) {
    sessionStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(tasks))
  } else {
    sessionStorage.removeItem(SESSION_STORAGE_KEY)
  }
}

const handleChange = (id) => ({ target }) => {
  const { checked } = target
  const approvedTasks = getApprovedTasks()
  if (checked) {
    setApprovedTasks([...approvedTasks, id])
  } else {
    const i = approvedTasks.indexOf(id)
    if (i >= 0) setApprovedTasks(approvedTasks.toSpliced(i, 1))
  }
}

function* collectTasks() {
  for (const input of document.querySelectorAll("td.accept > input[type=checkbox]")) {
    const { textContent } = input
      .parentElement
      .parentElement
      .firstChild
      .nextElementSibling
      .firstChild
    const [id] = textContent.match(/\w+/)
    yield [id, input]
  }
}

const approvedTasks = getApprovedTasks()
for (const [id, input] of collectTasks()) {
  input.addEventListener("change", handleChange(id))
  input.checked = approvedTasks.find(task => task === id) != null
}

const DEMOTION_STATUS_MESSAGE = "Not Approved by Engineering for Active Work"
const DEBOUNCE_TIMEOUT = 500
const CONFIRMATION_MESSAGE = "Are you sure you are ready to submit promotions and demotions"

const boardTaskPath = (id) => new URL(id, new URL(document.querySelector("link[rel~=board][rel~=task][rel~=path]").href))
const taskPath = (id) => new URL(id, new URL(document.querySelector("link[rel~=task][rel~=path]").href))
const csrfToken = () => document.querySelector("meta[name=csrf-token]").content

const sleep = (duration) => new Promise(resolve => setTimeout(resolve, duration))
const removeRow = ({ parentElement }) => {
  const { parentElement: row } = parentElement
  row.remove()
}
const handleClick = async () => {
  if (!confirm(CONFIRMATION_MESSAGE)) return

  for (const [id, input] of collectTasks()) {
    const { checked } = input
    await fetch(checked ? taskPath(id) : boardTaskPath(id), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken()
      },
      body: JSON.stringify({
        task: {
          approved: false,
          ...(!checked && { status: DEMOTION_STATUS_MESSAGE })
        }
      })
    })
    removeRow(input)
    await sleep(DEBOUNCE_TIMEOUT)
  }
}
document.querySelector("th > button[label=accept]")?.addEventListener("click", handleClick)
