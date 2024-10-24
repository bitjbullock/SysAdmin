document.addEventListener('DOMContentLoaded', function () {
  const tocList = document.getElementById('toc-list');
  const headers = document.querySelectorAll('h2');

  headers.forEach((header, index) => {
    if (!header.id) header.id = 'header-' + index;

    const listItem = document.createElement('li');
    const link = document.createElement('a');
    link.href = '#' + header.id;
    link.textContent = header.textContent;

    listItem.appendChild(link);
    tocList.appendChild(listItem);
  });

  if (headers.length === 0) {
    tocList.innerHTML = '<li>No headings found on this page.</li>';
  }
});
