const codeBlocks = document.querySelectorAll('figure > pre > code');
const copyCodeButtons = document.querySelectorAll('.copy-code-button');
copyCodeButtons.forEach((copyCodeButton, index) => {
  const code = codeBlocks[index].innerText;

  copyCodeButton.addEventListener('click', () => {
    window.navigator.clipboard.writeText(code);
    copyCodeButton.classList.remove('cp');
    copyCodeButton.classList.add('cp-done');
 
    setTimeout(() => {
      copyCodeButton.classList.remove('cp-done');
      copyCodeButton.classList.add('cp');
    }, 2000);
  });
});