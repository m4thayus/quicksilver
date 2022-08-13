import EasyMDE from "easyMDE"
import "easymde/dist/easymde.min.css"

document.querySelectorAll("textarea.markdown").forEach((element) => {
  new EasyMDE({
    element: element,
  })
})
