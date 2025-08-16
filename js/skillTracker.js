// js/skillTracker.js

let skillLevel = 'beginner';

function updateSkillLevel() {
    if (score > 100) {
        skillLevel = 'intermediate';
    } if (score > 200) {
        skillLevel = 'advanced';
    }
    // Adjust difficulty accordingly
}
