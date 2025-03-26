document.addEventListener("DOMContentLoaded", function () {
    const buttons = document.querySelectorAll(".popup-button");
    const overlay = document.getElementById("overlay");
    const closeButtons = document.querySelectorAll(".close-btn");

    // Open the corresponding popup
    buttons.forEach(button => {
        button.addEventListener("click", function () {
            const popupId = this.getAttribute("data-popup");
            document.getElementById(popupId).style.display = "block";
            overlay.style.display = "block";
        });
    });

    // Close popups when clicking on the close button
    closeButtons.forEach(button => {
        button.addEventListener("click", function () {
            this.closest(".popup").style.display = "none";
            overlay.style.display = "none";
        });
    });

    // Close popup when clicking outside it
    overlay.addEventListener("click", function () {
        document.querySelectorAll(".popup").forEach(popup => {
            popup.style.display = "none";
        });
        overlay.style.display = "none";
    });
});
