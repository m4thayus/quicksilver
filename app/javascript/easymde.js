import EasyMDE from "easymde"
import "easymde/dist/easymde.min.css"

document.querySelectorAll("textarea.markdown").forEach((element) => {
  new EasyMDE({
    element: element,
  })
})
