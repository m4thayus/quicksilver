import "./sortable-table.css";

const columnIndex = (th, n = 0) => th.previousElementSibling ? columnIndex(th.previousElementSibling, n + 1) : n;

const extractors = {
  date: (cell) => new Date(cell.querySelector("time[datetime]")?.dateTime ?? null),
  numeric: (cell) => Number(Array.from(cell.textContent)
    .filter(c => !isNaN(Number(c)))
    .join(""))
};
const comparators = {
  string: (a, b) => a.localeCompare(b)
};

for (const table of document.querySelectorAll("table")) {
  table.tHead.addEventListener("click", ({ target }) => {
    if (!target.matches(".sortable")) return;

    const { sorter = "string", direction = "down" } = target.dataset;
    const extractor = extractors[sorter] ?? ((cell) => cell.textContent);
    const comparator = comparators[sorter] ?? ((a, b) => a - b);

    const up = direction !== "up";
    const d = up ? 1 : -1;

    const index = columnIndex(target);
    delete table.tHead.querySelector("th[data-direction]")?.dataset.direction;
    target.dataset.direction = up ? "up" : "down";
    for (const body of table.tBodies) {
      const values = Array.from(body.rows).map((row, i) => [extractor(row.cells[index]), i]);
      values.sort(([a], [b]) => d * comparator(a, b));
      const sorted = values.map(([_, v]) => body.rows[v]);
      body.innerHTML = "";
      for (row of sorted) body.append(row);
    }
  });
}
