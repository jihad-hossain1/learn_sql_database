import { faker } from '@faker-js/faker';
import { dbClient } from '../db.mjs';

const START_DATE = new Date('2025-01-01T00:00:00Z');
const END_DATE = new Date('2025-03-31T23:59:59Z');

// Message types and content templates
const MESSAGE_TYPES = [
	'job_inquiry',
	'application_followup',
	'project_discussion',
	'payment_discussion',
	'general_inquiry',
];

const MESSAGE_TEMPLATES = {
	job_inquiry: [
		"Hi! I'm interested in your job posting. Can you provide more details about the requirements?",
		"Hello! I saw your job and I think I'd be a great fit. What's the timeline for this project?",
		'Hi there! I have experience with the technologies you mentioned. Would you like to discuss this further?',
		"Hello! I'm very interested in this opportunity. Can we schedule a call to discuss the details?",
	],
	application_followup: [
		"Hi! I submitted my application for your job. I'm excited about this opportunity and would love to discuss it further.",
		"Hello! I wanted to follow up on my application. I'm available for an interview anytime this week.",
		"Hi there! I'm checking in on my application status. I'm very interested in this position.",
	],
	project_discussion: [
		'Hi! I wanted to discuss the project timeline and deliverables.',
		'Hello! I have some questions about the project requirements. Can we clarify a few things?',
		"Hi there! I'm working on the first milestone and wanted to check in about the progress.",
	],
	payment_discussion: [
		'Hi! I wanted to discuss the payment terms for the project.',
		'Hello! I have a question about the milestone payments. Can we clarify the schedule?',
		'Hi there! I wanted to confirm the payment details for the completed work.',
	],
	general_inquiry: [
		'Hi! I have a general question about working together.',
		'Hello! I wanted to discuss potential future collaborations.',
		'Hi there! I have some questions about your services.',
	],
};

// Notification types and content
const NOTIFICATION_TYPES = [
	'application_received',
	'application_accepted',
	'application_rejected',
	'project_started',
	'milestone_completed',
	'payment_received',
	'review_received',
	'message_received',
];

const NOTIFICATION_TEMPLATES = {
	application_received: 'You received a new application for your job posting',
	application_accepted: 'Your application has been accepted!',
	application_rejected: 'Your application was not selected for this position',
	project_started:
		'Your project has started! Check the project dashboard for updates',
	milestone_completed: 'A milestone has been completed in your project',
	payment_received: 'Payment has been processed for your work',
	review_received: 'You received a new review from your client',
	message_received: 'You have a new message from',
};

function randomDateBetween(start, end) {
	return new Date(
		start.getTime() + Math.random() * (end.getTime() - start.getTime())
	);
}

// Safe array element selection with fallback
function safeArrayElement(array, fallback = null) {
	if (!array || array.length === 0) {
		return fallback;
	}
	return faker.helpers.arrayElement(array);
}

export async function seedMessages() {
	try {
		console.log('💬 Starting to seed messages...');

		// Start transaction
		await dbClient.query('BEGIN');

		// Get existing data
		const users = await dbClient.query(`
			SELECT id, user_type FROM users 
			WHERE account_status = 'active'
		`);

		const jobs = await dbClient.query(`
			SELECT id, client_id, title FROM jobs 
			WHERE status IN ('open', 'in_progress')
		`);

		const projects = await dbClient.query(`
			SELECT id, job_id, freelancer_id, status FROM projects 
			WHERE status IN ('in_progress', 'completed')
		`);

		if (users.rows.length === 0) {
			console.log('❌ No active users found');
			await dbClient.query('ROLLBACK');
			return;
		}

		console.log(
			`Found ${users.rows.length} users, ${jobs.rows.length} jobs, ${projects.rows.length} projects`
		);

		const messages = [];
		const messageCount = 5000; // Large number of messages

		for (let i = 0; i < messageCount; i++) {
			const sender = safeArrayElement(users.rows);
			const receiver = safeArrayElement(
				users.rows.filter((u) => u.id !== sender?.id)
			);

			if (!sender || !receiver) continue;

			const messageType = faker.helpers.arrayElement(MESSAGE_TYPES);
			const template = faker.helpers.arrayElement(
				MESSAGE_TEMPLATES[messageType]
			);
			const sentAt = randomDateBetween(START_DATE, END_DATE);

			const message = {
				sender_id: sender.id,
				receiver_id: receiver.id,
				content: template,
				sent_at: sentAt.toISOString(),
				job_id: null,
				project_id: null,
			};

			// Assign job_id or project_id based on message type
			if (
				messageType === 'job_inquiry' ||
				messageType === 'application_followup'
			) {
				const job = safeArrayElement(jobs.rows);
				if (job) {
					message.job_id = job.id;
				}
			} else if (
				messageType === 'project_discussion' ||
				messageType === 'payment_discussion'
			) {
				const project = safeArrayElement(projects.rows);
				if (project) {
					message.project_id = project.id;
				}
			}

			messages.push(message);
		}

		// Insert messages
		console.log('�� Inserting messages...');
		const messageColumns = [
			'sender_id',
			'receiver_id',
			'job_id',
			'project_id',
			'content',
			'sent_at',
		];

		const messageValuePlaceholders = [];
		const messageValues = [];

		messages.forEach((message, idx) => {
			const baseIdx = idx * messageColumns.length;
			messageValuePlaceholders.push(
				`(${messageColumns
					.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
					.join(', ')})`
			);
			messageValues.push(
				message.sender_id,
				message.receiver_id,
				message.job_id,
				message.project_id,
				message.content,
				message.sent_at
			);
		});

		const messageQuery = `
			INSERT INTO messages (${messageColumns.join(', ')})
			VALUES ${messageValuePlaceholders.join(',\n')}
		`;

		await dbClient.query(messageQuery, messageValues);
		console.log(`✅ Inserted ${messages.length} messages`);

		// Commit transaction
		await dbClient.query('COMMIT');
		console.log('🎉 Successfully seeded messages!');
	} catch (error) {
		await dbClient.query('ROLLBACK');
		console.error('❌ Error seeding messages:', error);
		throw error;
	}
}

export async function seedNotifications() {
	try {
		console.log('🔔 Starting to seed notifications...');

		// Start transaction
		await dbClient.query('BEGIN');

		// Get existing data
		const users = await dbClient.query(`
			SELECT id, user_type FROM users 
			WHERE account_status = 'active'
		`);

		const applications = await dbClient.query(`
			SELECT a.id, a.freelancer_id, j.client_id, j.title 
			FROM applications a 
			JOIN jobs j ON a.job_id = j.id
		`);

		const projects = await dbClient.query(`
			SELECT id, freelancer_id, job_id FROM projects
		`);

		const reviews = await dbClient.query(`
			SELECT id, reviewer_id, reviewee_id FROM reviews
		`);

		if (users.rows.length === 0) {
			console.log('❌ No active users found');
			await dbClient.query('ROLLBACK');
			return;
		}

		console.log(
			`Found ${users.rows.length} users, ${applications.rows.length} applications, ${projects.rows.length} projects`
		);

		const notifications = [];
		const notificationCount = 3000; // Large number of notifications

		for (let i = 0; i < notificationCount; i++) {
			const user = safeArrayElement(users.rows);
			if (!user) continue;

			const notificationType = faker.helpers.arrayElement(NOTIFICATION_TYPES);
			const template = NOTIFICATION_TEMPLATES[notificationType];
			const createdAt = randomDateBetween(START_DATE, END_DATE);
			const isRead = faker.datatype.boolean({ probability: 0.7 }); // 70% chance of being read

			let content = template;
			let relatedUserId = null;

			// Generate specific content based on notification type
			switch (notificationType) {
				case 'application_received':
					const application = safeArrayElement(applications.rows);
					if (application && application.client_id === user.id) {
						content = `New application received for job: "${application.title}"`;
						relatedUserId = application.freelancer_id;
					}
					break;

				case 'application_accepted':
				case 'application_rejected':
					const userApplication = safeArrayElement(
						applications.rows.filter((a) => a.freelancer_id === user.id)
					);
					if (userApplication) {
						content = `Your application for "${userApplication.title}" was ${
							notificationType === 'application_accepted'
								? 'accepted'
								: 'rejected'
						}`;
						relatedUserId = userApplication.client_id;
					}
					break;

				case 'project_started':
					const userProject = safeArrayElement(
						projects.rows.filter(
							(p) => p.freelancer_id === user.id || p.job_id === user.id
						)
					);
					if (userProject) {
						content =
							'Your project has started! Check the dashboard for updates.';
					}
					break;

				case 'milestone_completed':
					const project = safeArrayElement(projects.rows);
					if (project) {
						content = 'A milestone has been completed in your project.';
					}
					break;

				case 'payment_received':
					content = 'Payment has been processed for your work.';
					break;

				case 'review_received':
					const userReview = safeArrayElement(
						reviews.rows.filter((r) => r.reviewee_id === user.id)
					);
					if (userReview) {
						content = 'You received a new review from your client.';
						relatedUserId = userReview.reviewer_id;
					}
					break;

				case 'message_received':
					const otherUser = safeArrayElement(
						users.rows.filter((u) => u.id !== user.id)
					);
					if (otherUser) {
						content = `You have a new message from ${otherUser.user_type}`;
						relatedUserId = otherUser.id;
					}
					break;
			}

			const notification = {
				user_id: user.id,
				type: notificationType,
				content: content,
				is_read: isRead,
				created_at: createdAt.toISOString(),
			};

			notifications.push(notification);
		}

		// Insert notifications
		console.log('📝 Inserting notifications...');
		const notificationColumns = [
			'user_id',
			'type',
			'content',
			'is_read',
			'created_at',
		];

		const notificationValuePlaceholders = [];
		const notificationValues = [];

		notifications.forEach((notification, idx) => {
			const baseIdx = idx * notificationColumns.length;
			notificationValuePlaceholders.push(
				`(${notificationColumns
					.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
					.join(', ')})`
			);
			notificationValues.push(
				notification.user_id,
				notification.type,
				notification.content,
				notification.is_read,
				notification.created_at
			);
		});

		const notificationQuery = `
			INSERT INTO notifications (${notificationColumns.join(', ')})
			VALUES ${notificationValuePlaceholders.join(',\n')}
		`;

		await dbClient.query(notificationQuery, notificationValues);
		console.log(`✅ Inserted ${notifications.length} notifications`);

		// Commit transaction
		await dbClient.query('COMMIT');
		console.log('🎉 Successfully seeded notifications!');
	} catch (error) {
		await dbClient.query('ROLLBACK');
		console.error('❌ Error seeding notifications:', error);
		throw error;
	}
}

export async function seedReviews() {
	try {
		console.log('⭐ Starting to seed reviews...');

		// Start transaction
		await dbClient.query('BEGIN');

		// Get existing data
		const completedProjects = await dbClient.query(`
			SELECT p.id, p.freelancer_id, p.job_id, j.client_id, p.total_amount
			FROM projects p
			JOIN jobs j ON p.job_id = j.id
			WHERE p.status = 'completed'
		`);

		if (completedProjects.rows.length === 0) {
			console.log(
				'❌ No completed projects found. Please seed projects first.'
			);
			await dbClient.query('ROLLBACK');
			return;
		}

		console.log(`Found ${completedProjects.rows.length} completed projects`);

		const reviews = [];
		const reviewCount = Math.min(completedProjects.rows.length * 2, 500); // 2 reviews per project, max 500

		for (let i = 0; i < reviewCount; i++) {
			const project = safeArrayElement(completedProjects.rows);
			if (!project) continue;

			// Determine who is reviewing whom
			const isClientReviewing = faker.datatype.boolean(); // 50% chance
			const reviewerId = isClientReviewing
				? project.client_id
				: project.freelancer_id;
			const revieweeId = isClientReviewing
				? project.freelancer_id
				: project.client_id;

			const rating = faker.helpers.rangeToNumber({ min: 1, max: 5 });
			const createdAt = randomDateBetween(START_DATE, END_DATE);

			// Generate review comment based on rating
			let comment;
			if (rating >= 4) {
				comment = faker.helpers.arrayElement([
					'Excellent work! Very professional and delivered on time.',
					'Great communication and high-quality deliverables.',
					'Highly recommended! Exceeded expectations.',
					'Outstanding work quality and attention to detail.',
					'Very satisfied with the results. Would work together again!',
				]);
			} else if (rating >= 3) {
				comment = faker.helpers.arrayElement([
					'Good work overall, met the basic requirements.',
					'Decent quality, some room for improvement.',
					'Acceptable work, communication was okay.',
					'Project completed successfully, minor issues.',
					'Fair work quality, would consider for future projects.',
				]);
			} else {
				comment = faker.helpers.arrayElement([
					'Work was completed but quality could be better.',
					'Some issues with communication and timeline.',
					'Project delivered but not up to expectations.',
					'Basic requirements met but quality was lacking.',
					'Work completed but would not recommend.',
				]);
			}

			const review = {
				project_id: project.id,
				reviewer_id: reviewerId,
				reviewee_id: revieweeId,
				rating: rating,
				comment: comment,
				created_at: createdAt.toISOString(),
			};

			reviews.push(review);
		}

		// Insert reviews
		console.log('📝 Inserting reviews...');
		const reviewColumns = [
			'project_id',
			'reviewer_id',
			'reviewee_id',
			'rating',
			'comment',
			'created_at',
		];

		const reviewValuePlaceholders = [];
		const reviewValues = [];

		reviews.forEach((review, idx) => {
			const baseIdx = idx * reviewColumns.length;
			reviewValuePlaceholders.push(
				`(${reviewColumns
					.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
					.join(', ')})`
			);
			reviewValues.push(
				review.project_id,
				review.reviewer_id,
				review.reviewee_id,
				review.rating,
				review.comment,
				review.created_at
			);
		});

		const reviewQuery = `
			INSERT INTO reviews (${reviewColumns.join(', ')})
			VALUES ${reviewValuePlaceholders.join(',\n')}
		`;

		await dbClient.query(reviewQuery, reviewValues);
		console.log(`✅ Inserted ${reviews.length} reviews`);

		// Update average ratings for users
		console.log('📊 Updating user average ratings...');
		const ratingUpdateQuery = `
			UPDATE users 
			SET average_rating = (
				SELECT COALESCE(AVG(rating), 0)
				FROM reviews 
				WHERE reviewee_id = users.id
			)
		`;
		await dbClient.query(ratingUpdateQuery);

		// Commit transaction
		await dbClient.query('COMMIT');
		console.log('🎉 Successfully seeded reviews!');
	} catch (error) {
		await dbClient.query('ROLLBACK');
		console.error('❌ Error seeding reviews:', error);
		throw error;
	}
}

// Verification functions
export async function verifyMessageSeeding() {
	try {
		const messageCount = await dbClient.query('SELECT COUNT(*) FROM messages');
		console.log(`📊 Messages: ${messageCount.rows[0].count}`);

		// Check relationships
		const orphanedMessages = await dbClient.query(`
			SELECT COUNT(*) FROM messages m
			LEFT JOIN users u1 ON m.sender_id = u1.id
			LEFT JOIN users u2 ON m.receiver_id = u2.id
			WHERE u1.id IS NULL OR u2.id IS NULL
		`);

		if (orphanedMessages.rows[0].count > 0) {
			console.log('⚠️  Warning: Found orphaned messages');
		} else {
			console.log('✅ All messages have valid user relationships');
		}
	} catch (error) {
		console.error('❌ Error verifying message seeding:', error);
	}
}

export async function verifyNotificationSeeding() {
	try {
		const notificationCount = await dbClient.query(
			'SELECT COUNT(*) FROM notifications'
		);
		console.log(`📊 Notifications: ${notificationCount.rows[0].count}`);

		// Check relationships
		const orphanedNotifications = await dbClient.query(`
			SELECT COUNT(*) FROM notifications n
			LEFT JOIN users u ON n.user_id = u.id
			WHERE u.id IS NULL
		`);

		if (orphanedNotifications.rows[0].count > 0) {
			console.log('⚠️  Warning: Found orphaned notifications');
		} else {
			console.log('✅ All notifications have valid user relationships');
		}
	} catch (error) {
		console.error('❌ Error verifying notification seeding:', error);
	}
}

export async function verifyReviewSeeding() {
	try {
		const reviewCount = await dbClient.query('SELECT COUNT(*) FROM reviews');
		console.log(`📊 Reviews: ${reviewCount.rows[0].count}`);

		// Check relationships
		const orphanedReviews = await dbClient.query(`
			SELECT COUNT(*) FROM reviews r
			LEFT JOIN projects p ON r.project_id = p.id
			LEFT JOIN users u1 ON r.reviewer_id = u1.id
			LEFT JOIN users u2 ON r.reviewee_id = u2.id
			WHERE p.id IS NULL OR u1.id IS NULL OR u2.id IS NULL
		`);

		if (orphanedReviews.rows[0].count > 0) {
			console.log('⚠️  Warning: Found orphaned reviews');
		} else {
			console.log('✅ All reviews have valid relationships');
		}
	} catch (error) {
		console.error('❌ Error verifying review seeding:', error);
	}
}
