// Script to be included at the end of converted Markdown files

addEventListener("load", _ => {
  // Disable all checkboxes, this is a static site and having interactive
  // elements is misleading.
  document.querySelectorAll("input").forEach(checkbox => {
    checkbox.disabled = true;
  });
});
