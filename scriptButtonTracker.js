
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded');
    console.log('Current page title:', document.title);


    const popupToDisplayName = {
        popup0: 'Introduction Page',
        popup1: 'Patch Scanner',
        popup2: 'Backup Scanner',
        popup3: 'Password Scanner',
        popup4: 'Baseline Scanner',
        popup5: 'Sensitive Data Scanner',
        popup6: 'Inventory Scanner',
        popup7: 'Port Scanner',
        popup8: 'Brute Force Scanner',
        popup9: 'Network Adapter Scanner'
    };

    if (document.title === 'Check-The-List - Cybersecurity Hardening') {
        console.log('On Button Tracker page');
        const buttons = document.querySelectorAll('.popup-button');
        console.log('Found buttons:', buttons.length);

        buttons.forEach(button => {
            button.addEventListener('click', () => {
                console.log('Button clicked');
                const popupId = button.getAttribute('data-popup');
                trackButtonClick(popupId);
            });
        });
    } else if (document.title === 'Check-The-List Cybersecurity Hardening') {
        console.log('On Dashboard page');
        const clickList = document.getElementById('recent-clicks');
        const noClicksMsg = document.getElementById('no-clicks');

        console.log('clickList element:', clickList);
        console.log('noClicksMsg element:', noClicksMsg);

        if (!clickList || !noClicksMsg) {
            console.error('Required elements not found on dashboard page');
            return;
        }

        const recentClicksRaw = localStorage.getItem('recentClicks');
        console.log('Raw recentClicks from localStorage:', recentClicksRaw);

        let recentClicks;
        try {
            recentClicks = JSON.parse(recentClicksRaw) || [];
        } catch (error) {
            console.error('Error parsing recentClicks from localStorage:', error);
            recentClicks = [];
        }
        console.log('Parsed recentClicks:', recentClicks);

        if (recentClicks.length === 0) {
            console.log('No recent clicks, showing no-clicks message');
            noClicksMsg.style.display = 'block';
            clickList.style.display = 'none';
        } else {
            console.log('Displaying recent clicks');
            noClicksMsg.style.display = 'none';
            clickList.style.display = 'block';

            recentClicks.forEach(click => {
                console.log('Adding click to list:', click);
                const li = document.createElement('li');
                li.textContent = popupToDisplayName[click] || click;
                clickList.appendChild(li);
            });
        }
    } else {
        console.log('Page title does not match expected values');
    }
});

function trackButtonClick(popupId) {
    console.log(`Tracking button with data-popup: ${popupId}`);
    let recentClicks = JSON.parse(localStorage.getItem('recentClicks')) || [];


    const existingIndex = recentClicks.indexOf(popupId);
    if (existingIndex !== -1) {
        console.log(`Popup ${popupId} already in list at index ${existingIndex}, moving to top`);
        recentClicks.splice(existingIndex, 1);
    } else {
        console.log(`Popup ${popupId} not in list, adding as new entry`);
    }

    recentClicks.unshift(popupId);


    if (recentClicks.length > 3) {
        recentClicks = recentClicks.slice(0, 3);
    }

    console.log('Saving to localStorage:', recentClicks);
    localStorage.setItem('recentClicks', JSON.stringify(recentClicks));
}