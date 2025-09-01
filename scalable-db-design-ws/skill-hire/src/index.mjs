import {
	seedUsersWithProfiles,
	seedSkills,
	verifySeeding,
} from './seeds/users.mjs';
import { seedJobsAndRelatedData, verifyJobSeeding } from './seeds/jobs.mjs';
import {
	seedMessages,
	seedNotifications,
	seedReviews,
	verifyMessageSeeding,
	verifyNotificationSeeding,
	verifyReviewSeeding,
} from './seeds/messages.mjs';

(async function main() {
	// Seed skills
	await seedSkills();

	// Seed users
	await seedUsersWithProfiles(250);
	await verifySeeding();

	// Seed jobs
	await seedJobsAndRelatedData(100);
	await verifyJobSeeding();

	// Seed Messages
	await seedMessages();
	await verifyMessageSeeding();

	// Seed Notifications
	await seedNotifications();
	await verifyNotificationSeeding();

	// Seed Reviews
	await seedReviews();
	await verifyReviewSeeding();
})();
