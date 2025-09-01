import { faker } from '@faker-js/faker';
import { dbClient } from '../db.mjs';

const BUDGET_TYPES = ['fixed', 'hourly'];
const JOB_STATUSES = ['open', 'in_progress', 'completed', 'closed'];
const APPLICATION_STATUSES = ['pending', 'accepted', 'rejected'];
const PROJECT_STATUSES = ['pending', 'in_progress', 'completed', 'cancelled'];
const MILESTONE_STATUSES = ['pending', 'completed', 'paid'];

const START_DATE = new Date('2024-11-01T00:00:00Z');
const END_DATE = new Date('2025-03-31T23:59:59Z');

// Job categories and their typical skills
const JOB_CATEGORIES = [
	{
		id: 1,
		name: 'Web Development',
		description: 'Frontend and backend web development',
	},
	{
		id: 2,
		name: 'Mobile Development',
		description: 'iOS and Android app development',
	},
	{
		id: 3,
		name: 'Data Science',
		description: 'Machine learning and data analysis',
	},
	{ id: 4, name: 'DevOps', description: 'Infrastructure and deployment' },
	{
		id: 5,
		name: 'UI/UX Design',
		description: 'User interface and experience design',
	},
	{
		id: 6,
		name: 'Content Writing',
		description: 'Copywriting and content creation',
	},
	{
		id: 7,
		name: 'Digital Marketing',
		description: 'SEO, social media, and marketing',
	},
	{
		id: 8,
		name: 'Graphic Design',
		description: 'Logo, branding, and visual design',
	},
];

const JOB_TITLES = [
	'React Developer Needed for E-commerce Platform',
	'Full-Stack Developer for SaaS Application',
	'Mobile App Developer for Food Delivery App',
	'UI/UX Designer for Healthcare Platform',
	'DevOps Engineer for Cloud Migration',
	'Data Scientist for Customer Analytics',
	'WordPress Developer for Corporate Website',
	'Python Developer for API Development',
	'Vue.js Developer for Real Estate Platform',
	'Node.js Developer for Chat Application',
	'Flutter Developer for Fitness App',
	'Angular Developer for Admin Dashboard',
	'Laravel Developer for CRM System',
	'Django Developer for E-learning Platform',
	'Swift Developer for iOS App',
	'Kotlin Developer for Android App',
	'Machine Learning Engineer for Recommendation System',
	'Blockchain Developer for DeFi Platform',
	'GraphQL Developer for API Gateway',
	'Microservices Developer for Banking System',
];

function randomDateBetween(start, end) {
	return new Date(
		start.getTime() + Math.random() * (end.getTime() - start.getTime())
	);
}

function randomDateInFuture(fromDate, daysRange = 30) {
	const futureDate = new Date(fromDate);
	futureDate.setDate(futureDate.getDate() + Math.random() * daysRange);
	return futureDate;
}

// Safe array element selection with fallback
function safeArrayElement(array, fallback = null) {
	if (!array || array.length === 0) {
		return fallback;
	}
	return faker.helpers.arrayElement(array);
}

export async function seedJobsAndRelatedData() {
	try {
		console.log('🌱 Starting to seed jobs and related data...');

		// Start transaction
		await dbClient.query('BEGIN');

		// 1. Get existing data from database
		const clients = await dbClient.query(`
			SELECT u.id, cp.company_name, cp.location 
			FROM users u 
			JOIN client_profiles cp ON u.id = cp.id 
			WHERE u.user_type = 'client' AND u.account_status = 'active'
		`);

		const freelancers = await dbClient.query(`
			SELECT u.id, fp.name, fp.hourly_rate, fp.skills
			FROM users u 
			JOIN freelancer_profiles fp ON u.id = fp.id 
			WHERE u.user_type = 'freelancer' AND u.account_status = 'active'
		`);

		const skills = await dbClient.query('SELECT id, name FROM skills');
		const categories = await dbClient.query('SELECT id, name FROM categories');

		// Check if we have the required data
		if (clients.rows.length === 0) {
			console.log('❌ No active clients found. Please seed users first.');
			await dbClient.query('ROLLBACK');
			return;
		}

		if (freelancers.rows.length === 0) {
			console.log('❌ No active freelancers found. Please seed users first.');
			await dbClient.query('ROLLBACK');
			return;
		}

		if (skills.rows.length === 0) {
			console.log('❌ No skills found. Please seed skills first.');
			await dbClient.query('ROLLBACK');
			return;
		}

		console.log(
			`Found ${clients.rows.length} clients, ${freelancers.rows.length} freelancers, and ${skills.rows.length} skills`
		);

		// 2. Seed categories if not exists
		if (categories.rows.length === 0) {
			console.log(' Seeding categories...');
			const categoryColumns = ['id', 'name', 'description'];
			const categoryValues = [];
			const categoryPlaceholders = [];

			JOB_CATEGORIES.forEach((category, idx) => {
				const baseIdx = idx * categoryColumns.length;
				categoryPlaceholders.push(
					`(${categoryColumns
						.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
						.join(', ')})`
				);
				categoryValues.push(category.id, category.name, category.description);
			});

			const categoryQuery = `
				INSERT INTO categories (${categoryColumns.join(', ')})
				VALUES ${categoryPlaceholders.join(',\n')}
				ON CONFLICT (id) DO NOTHING
			`;

			await dbClient.query(categoryQuery, categoryValues);
			console.log(`✅ Seeded ${JOB_CATEGORIES.length} categories`);

			// Refresh categories after insertion
			const newCategories = await dbClient.query(
				'SELECT id, name FROM categories'
			);
			categories.rows = newCategories.rows;
		}

		// 3. Generate jobs
		const jobs = [];
		const jobSkills = [];
		const applications = [];
		const projects = [];
		const milestones = [];

		for (let i = 0; i < 100; i++) {
			const client = safeArrayElement(clients.rows);
			const category = safeArrayElement(categories.rows);

			// Skip if we don't have required data
			if (!client || !category) {
				console.log('⚠️  Skipping job creation due to missing data');
				continue;
			}

			const budgetType = faker.helpers.arrayElement(BUDGET_TYPES);
			const status = faker.helpers.arrayElement(JOB_STATUSES);
			const createdAt = randomDateBetween(START_DATE, END_DATE);
			const deadline = randomDateInFuture(createdAt, 60);
			const updatedAt = randomDateBetween(createdAt, END_DATE);

			// Generate budget amount based on type
			const budgetAmount =
				budgetType === 'fixed'
					? faker.helpers.rangeToNumber({ min: 500, max: 50000 })
					: faker.helpers.rangeToNumber({ min: 15, max: 200 });

			const job = {
				client_id: client.id,
				title: faker.helpers.arrayElement(JOB_TITLES),
				description: faker.lorem.paragraphs(2),
				category_id: category.id,
				budget_type: budgetType,
				budget_amount: budgetAmount,
				deadline: deadline.toISOString().split('T')[0],
				status: status,
				created_at: createdAt.toISOString(),
				updated_at: updatedAt.toISOString(),
				applications_count: 0, // Will be updated after applications
				category_name: category.name,
				job_index: i, // Add job index for tracking
			};

			jobs.push(job);

			// Generate 10-50 applications per job
			const numApplications = faker.helpers.rangeToNumber({ min: 10, max: 50 });
			const jobApplications = [];

			for (let j = 0; j < numApplications; j++) {
				const freelancer = safeArrayElement(freelancers.rows);
				if (!freelancer) continue;

				const appliedAt = randomDateBetween(createdAt, updatedAt);
				const proposedRate =
					budgetType === 'fixed'
						? faker.helpers.rangeToNumber({
								min: budgetAmount * 0.8,
								max: budgetAmount * 1.2,
						  })
						: faker.helpers.rangeToNumber({
								min: Math.max(10, budgetAmount * 0.8),
								max: budgetAmount * 1.5,
						  });

				const application = {
					job_id: null, // Will be set after job insertion
					freelancer_id: freelancer.id,
					cover_letter: faker.lorem.paragraphs(1),
					proposed_rate: proposedRate,
					status: faker.helpers.arrayElement(APPLICATION_STATUSES),
					applied_at: appliedAt.toISOString(),
				};

				jobApplications.push(application);
			}

			applications.push(...jobApplications);

			// Generate job skills (2-6 skills per job)
			const jobSkillCount = faker.helpers.rangeToNumber({ min: 2, max: 6 });
			const selectedSkills = faker.helpers.arrayElements(
				skills.rows,
				Math.min(jobSkillCount, skills.rows.length)
			);

			selectedSkills.forEach((skill) => {
				jobSkills.push({
					job_index: i, // Track which job this skill belongs to
					skill_id: skill.id,
				});
			});

			// Create projects for some completed jobs
			if (
				status === 'completed' &&
				faker.datatype.boolean({ probability: 0.3 }) &&
				jobApplications.length > 0
			) {
				const acceptedApplication = safeArrayElement(jobApplications);
				if (!acceptedApplication) continue;

				const startDate = randomDateBetween(createdAt, deadline);
				const endDate = randomDateInFuture(startDate, 30);
				const totalAmount =
					budgetType === 'fixed'
						? budgetAmount
						: budgetAmount * faker.helpers.rangeToNumber({ min: 20, max: 100 });

				const project = {
					job_id: null, // Will be set after job insertion
					freelancer_id: acceptedApplication.freelancer_id,
					status: 'completed',
					start_date: startDate.toISOString().split('T')[0],
					end_date: endDate.toISOString().split('T')[0],
					total_amount: totalAmount,
					created_at: startDate.toISOString(),
				};

				projects.push(project);

				// Generate milestones for projects
				const milestoneCount = faker.helpers.rangeToNumber({ min: 2, max: 5 });
				const milestoneAmount = totalAmount / milestoneCount;

				for (let k = 0; k < milestoneCount; k++) {
					const milestoneDate = new Date(startDate);
					milestoneDate.setDate(milestoneDate.getDate() + k * 7); // Weekly milestones

					const milestone = {
						project_id: null, // Will be set after project insertion
						description: `Milestone ${k + 1}: ${faker.lorem.sentence()}`,
						due_date: milestoneDate.toISOString().split('T')[0],
						amount: milestoneAmount,
						status: k < milestoneCount - 1 ? 'completed' : 'completed',
						created_at: milestoneDate.toISOString(),
						updated_at: milestoneDate.toISOString(),
					};

					milestones.push(milestone);
				}
			}
		}

		if (jobs.length === 0) {
			console.log('❌ No jobs could be created due to missing data');
			await dbClient.query('ROLLBACK');
			return;
		}

		// 4. Insert jobs
		console.log('💼 Inserting jobs...');
		const jobColumns = [
			'client_id',
			'title',
			'description',
			'category_id',
			'budget_type',
			'budget_amount',
			'deadline',
			'status',
			'created_at',
			'updated_at',
			'applications_count',
			'category_name',
		];

		const jobValuePlaceholders = [];
		const jobValues = [];
		jobs.forEach((job, idx) => {
			const baseIdx = idx * jobColumns.length;
			jobValuePlaceholders.push(
				`(${jobColumns
					.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
					.join(', ')})`
			);
			jobValues.push(
				job.client_id,
				job.title,
				job.description,
				job.category_id,
				job.budget_type,
				job.budget_amount,
				job.deadline,
				job.status,
				job.created_at,
				job.updated_at,
				job.applications_count,
				job.category_name
			);
		});

		const jobQuery = `
			INSERT INTO jobs (${jobColumns.join(', ')})
			VALUES ${jobValuePlaceholders.join(',\n')}
			RETURNING id
		`;

		const jobResult = await dbClient.query(jobQuery, jobValues);
		console.log(`✅ Inserted ${jobs.length} jobs`);

		// 5. Insert job skills
		if (jobSkills.length > 0) {
			console.log('🔗 Inserting job skills...');
			const jobSkillColumns = ['job_id', 'skill_id'];
			const jobSkillValuePlaceholders = [];
			const jobSkillValues = [];

			jobSkills.forEach((jobSkill, idx) => {
				// Find the corresponding job using job_index
				const jobId = jobResult.rows[jobSkill.job_index]?.id;
				if (!jobId) {
					console.log(`⚠️  Skipping job skill ${idx} - job not found`);
					return;
				}

				const baseIdx = idx * jobSkillColumns.length;
				jobSkillValuePlaceholders.push(
					`(${jobSkillColumns
						.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
						.join(', ')})`
				);
				jobSkillValues.push(jobId, jobSkill.skill_id);
			});

			if (jobSkillValuePlaceholders.length > 0) {
				const jobSkillQuery = `
					INSERT INTO job_skills (${jobSkillColumns.join(', ')})
					VALUES ${jobSkillValuePlaceholders.join(',\n')}
					ON CONFLICT (job_id, skill_id) DO NOTHING
				`;

				await dbClient.query(jobSkillQuery, jobSkillValues);
				console.log(
					`✅ Inserted ${jobSkillValuePlaceholders.length} job skills`
				);
			}
		}

		// 6. Insert applications
		if (applications.length > 0) {
			console.log('📝 Inserting applications...');
			const applicationColumns = [
				'job_id',
				'freelancer_id',
				'cover_letter',
				'proposed_rate',
				'status',
				'applied_at',
			];

			const applicationValuePlaceholders = [];
			const applicationValues = [];
			let jobIndex = 0;
			let applicationsPerJob = Math.floor(applications.length / jobs.length);

			applications.forEach((application, idx) => {
				if (idx > 0 && idx % applicationsPerJob === 0) {
					jobIndex++;
				}

				application.job_id =
					jobResult.rows[jobIndex]?.id || jobResult.rows[0].id;

				const baseIdx = idx * applicationColumns.length;
				applicationValuePlaceholders.push(
					`(${applicationColumns
						.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
						.join(', ')})`
				);
				applicationValues.push(
					application.job_id,
					application.freelancer_id,
					application.cover_letter,
					application.proposed_rate,
					application.status,
					application.applied_at
				);
			});

			const applicationQuery = `
				INSERT INTO applications (${applicationColumns.join(', ')})
				VALUES ${applicationValuePlaceholders.join(',\n')}
			`;

			await dbClient.query(applicationQuery, applicationValues);
			console.log(`✅ Inserted ${applications.length} applications`);
		}

		// 7. Update applications_count in jobs
		console.log('📊 Updating job application counts...');
		for (let i = 0; i < jobs.length; i++) {
			const jobId = jobResult.rows[i].id;
			const applicationCount = applications.filter(
				(app) => app.job_id === jobId
			).length;

			await dbClient.query(
				'UPDATE jobs SET applications_count = $1 WHERE id = $2',
				[applicationCount, jobId]
			);
		}

		// 8. Insert projects
		if (projects.length > 0) {
			console.log(' Inserting projects...');
			const projectColumns = [
				'job_id',
				'freelancer_id',
				'status',
				'start_date',
				'end_date',
				'total_amount',
				'created_at',
			];

			const projectValuePlaceholders = [];
			const projectValues = [];
			projects.forEach((project, idx) => {
				// Find corresponding job
				const jobId =
					jobResult.rows.find((job) => job.id === project.job_id)?.id ||
					jobResult.rows[0].id;

				project.job_id = jobId;

				const baseIdx = idx * projectColumns.length;
				projectValuePlaceholders.push(
					`(${projectColumns
						.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
						.join(', ')})`
				);
				projectValues.push(
					project.job_id,
					project.freelancer_id,
					project.status,
					project.start_date,
					project.end_date,
					project.total_amount,
					project.created_at
				);
			});

			const projectQuery = `
				INSERT INTO projects (${projectColumns.join(', ')})
				VALUES ${projectValuePlaceholders.join(',\n')}
				RETURNING id
			`;

			const projectResult = await dbClient.query(projectQuery, projectValues);
			console.log(`✅ Inserted ${projects.length} projects`);

			// 9. Insert milestones
			if (milestones.length > 0) {
				console.log('🎯 Inserting milestones...');
				const milestoneColumns = [
					'project_id',
					'description',
					'due_date',
					'amount',
					'status',
					'created_at',
					'updated_at',
				];

				const milestoneValuePlaceholders = [];
				const milestoneValues = [];
				milestones.forEach((milestone, idx) => {
					// Assign project_id to milestones
					const projectIndex = Math.floor(idx / 3); // Assuming 3 milestones per project
					milestone.project_id =
						projectResult.rows[projectIndex]?.id || projectResult.rows[0].id;

					const baseIdx = idx * milestoneColumns.length;
					milestoneValuePlaceholders.push(
						`(${milestoneColumns
							.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
							.join(', ')})`
					);
					milestoneValues.push(
						milestone.project_id,
						milestone.description,
						milestone.due_date,
						milestone.amount,
						milestone.status,
						milestone.created_at,
						milestone.updated_at
					);
				});

				const milestoneQuery = `
					INSERT INTO milestones (${milestoneColumns.join(', ')})
					VALUES ${milestoneValuePlaceholders.join(',\n')}
				`;

				await dbClient.query(milestoneQuery, milestoneValues);
				console.log(`✅ Inserted ${milestones.length} milestones`);
			}
		}

		// Commit transaction
		await dbClient.query('COMMIT');
		console.log('🎉 Successfully seeded all jobs and related data!');
	} catch (error) {
		// Rollback on error
		await dbClient.query('ROLLBACK');
		console.error('❌ Error seeding jobs:', error);
		throw error;
	}
}

// Verification function
export async function verifyJobSeeding() {
	try {
		const jobCount = await dbClient.query('SELECT COUNT(*) FROM jobs');
		const applicationCount = await dbClient.query(
			'SELECT COUNT(*) FROM applications'
		);
		const projectCount = await dbClient.query('SELECT COUNT(*) FROM projects');
		const milestoneCount = await dbClient.query(
			'SELECT COUNT(*) FROM milestones'
		);
		const jobSkillCount = await dbClient.query(
			'SELECT COUNT(*) FROM job_skills'
		);

		console.log('📊 Job Seeding Verification:');
		console.log(`Jobs: ${jobCount.rows[0].count}`);
		console.log(`Applications: ${applicationCount.rows[0].count}`);
		console.log(`Projects: ${projectCount.rows[0].count}`);
		console.log(`Milestones: ${milestoneCount.rows[0].count}`);
		console.log(`Job Skills: ${jobSkillCount.rows[0].count}`);

		// Check relationships
		const orphanedApplications = await dbClient.query(`
			SELECT COUNT(*) FROM applications a
			LEFT JOIN jobs j ON a.job_id = j.id
			WHERE j.id IS NULL
		`);

		const orphanedProjects = await dbClient.query(`
			SELECT COUNT(*) FROM projects p
			LEFT JOIN jobs j ON p.job_id = j.id
			WHERE j.id IS NULL
		`);

		if (orphanedApplications.rows[0].count > 0) {
			console.log('⚠️  Warning: Found orphaned applications');
		} else {
			console.log('✅ All applications have valid job relationships');
		}

		if (orphanedProjects.rows[0].count > 0) {
			console.log('⚠️  Warning: Found orphaned projects');
		} else {
			console.log('✅ All projects have valid job relationships');
		}
	} catch (error) {
		console.error('❌ Error verifying job seeding:', error);
	}
}
