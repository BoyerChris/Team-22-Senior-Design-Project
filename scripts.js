// Function to open modal with specific script information
function openModal(title, description, downloadLink) {
    document.getElementById("scriptTitle").innerText = title;
    document.getElementById("scriptDescription").innerText = description;
    document.getElementById("downloadButton").onclick = function() {
        window.location.href = downloadLink;
    };

    document.getElementById("scriptModal").style.display = "flex";
}

// Function to close modal
function closeModal() {
    document.getElementById("scriptModal").style.display = "none";
}

// Close the modal when clicking outside of it
window.onclick = function(event) {
    const modal = document.getElementById("scriptModal");
    if (event.target == modal) {
        closeModal();
    }
}
