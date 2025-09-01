import { faker } from '@faker-js/faker';
import { dbClient } from '../db.mjs';

const ACCOUNT_STATUSES = ['active', 'inactive', 'suspended'];
const START_DATE = new Date('2024-11-01T00:00:00Z');
const END_DATE = new Date('2025-03-31T23:59:59Z');

// Define all available skills
const ALL_SKILLS = [
	'JavaScript',
	'Python',
	'React',
	'Node.js',
	'PHP',
	'Java',
	'C#',
	'Ruby',
	'Go',
	'Rust',
	'TypeScript',
	'Vue.js',
	'Angular',
	'Django',
	'Flask',
	'Express',
	'Laravel',
	'Spring Boot',
	'ASP.NET',
	'GraphQL',
	'REST API',
	'MongoDB',
	'PostgreSQL',
	'MySQL',
	'Redis',
	'Docker',
	'Kubernetes',
	'AWS',
	'Azure',
	'GCP',
	'CI/CD',
	'Git',
	'Agile',
	'Scrum',
	'HTML',
	'CSS',
	'Sass',
	'Less',
	'Bootstrap',
	'Tailwind CSS',
	'jQuery',
	'Webpack',
	'Babel',
	'ESLint',
	'Prettier',
	'Jest',
	'Cypress',
	'Selenium',
	'JUnit',
	'Mocha',
	'Chai',
	'Sinon',
	'Redux',
	'Vuex',
	'MobX',
	'Zustand',
	'Next.js',
	'Nuxt.js',
	'Gatsby',
	'Strapi',
	'Sanity',
	'Contentful',
	'Stripe',
	'PayPal',
	'Firebase',
	'Supabase',
	'Auth0',
	'JWT',
	'OAuth',
	'OpenID Connect',
];

function randomDateBetween(start, end) {
	return new Date(
		start.getTime() + Math.random() * (end.getTime() - start.getTime())
	);
}

// First, seed the skills table
export async function seedSkills() {
	try {
		console.log('🌱 Seeding skills table...');

		const skillColumns = ['id', 'name', 'description'];
		const skillValuePlaceholders = [];
		const skillValues = [];

		ALL_SKILLS.forEach((skill, idx) => {
			const baseIdx = idx * skillColumns.length;
			skillValuePlaceholders.push(
				`(${skillColumns
					.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
					.join(', ')})`
			);
			skillValues.push(
				idx + 1, // id
				skill, // name
				`Expertise in ${skill} development and implementation` // description
			);
		});

		const skillQuery = `
			INSERT INTO skills (${skillColumns.join(', ')})
			VALUES ${skillValuePlaceholders.join(',\n')}
			ON CONFLICT (id) DO NOTHING
		`;

		await dbClient.query(skillQuery, skillValues);
		console.log(`✅ Inserted ${ALL_SKILLS.length} skills`);
	} catch (error) {
		console.error('❌ Error seeding skills:', error);
		throw error;
	}
}

export async function seedUsersWithProfiles(count = 100) {
	const users = [];
	const freelancerProfiles = [];
	const clientProfiles = [];

	// Calculate distribution: 75% freelancers, 25% clients
	const numClients = Math.floor(count * 0.25);
	const numFreelancers = count - numClients;

	console.log(
		`Seeding ${numFreelancers} freelancers and ${numClients} clients...`
	);

	// Generate users with profiles
	for (let i = 0; i < count; i++) {
		const createdAt = randomDateBetween(START_DATE, END_DATE);
		const updatedAt = randomDateBetween(createdAt, END_DATE);
		const userType = i < numFreelancers ? 'freelancer' : 'client';

		const user = {
			email: faker.internet.email(),
			password: faker.internet.password(),
			user_type: userType,
			account_status: faker.helpers.arrayElement(ACCOUNT_STATUSES),
			created_at: createdAt.toISOString(),
			updated_at: updatedAt.toISOString(),
			average_rating: faker.helpers.rangeToNumber({ min: 1, max: 5 }),
		};

		users.push(user);

		// Create corresponding profile based on user type
		if (userType === 'freelancer') {
			// Select random skills for this freelancer
			const selectedSkills = faker.helpers.arrayElements(ALL_SKILLS, {
				min: 2,
				max: 8,
			});

			freelancerProfiles.push({
				name: faker.person.fullName(),
				location: faker.location.city(),
				hourly_rate: faker.helpers.rangeToNumber({ min: 10, max: 200 }),
				is_available: faker.datatype.boolean(),
				portfolio: {
					projects: faker.helpers.rangeToNumber({ min: 0, max: 20 }),
					experience_years: faker.helpers.rangeToNumber({ min: 1, max: 15 }),
					completed_projects: faker.helpers.rangeToNumber({ min: 0, max: 50 }),
				},
				skills: selectedSkills, // Array of skill names for JSONB
				skillIds: [], // Will be populated with actual skill IDs
			});
		} else {
			clientProfiles.push({
				company_name: faker.company.name(),
				description: faker.company.catchPhrase(),
				location: faker.location.city(),
				contact_info: {
					phone: faker.phone.number(),
					website: faker.internet.url(),
					linkedin: faker.internet.url(),
				},
			});
		}
	}

	if (users.length === 0) {
		console.log('No users to insert.');
		return;
	}

	try {
		// Start transaction
		await dbClient.query('BEGIN');

		// 1. Insert users first
		const userColumns = [
			'email',
			'password',
			'user_type',
			'account_status',
			'created_at',
			'updated_at',
			'average_rating',
		];

		const userValuePlaceholders = [];
		const userValues = [];
		users.forEach((user, idx) => {
			const baseIdx = idx * userColumns.length;
			userValuePlaceholders.push(
				`(${userColumns
					.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
					.join(', ')})`
			);
			userValues.push(
				user.email,
				user.password,
				user.user_type,
				user.account_status,
				user.created_at,
				user.updated_at,
				user.average_rating
			);
		});

		const userQuery = `
			INSERT INTO users (${userColumns.join(', ')})
			VALUES ${userValuePlaceholders.join(',\n')}
			RETURNING id, user_type
		`;

		const userResult = await dbClient.query(userQuery, userValues);
		console.log(`Inserted ${users.length} users`);

		// 2. Insert freelancer profiles
		if (freelancerProfiles.length > 0) {
			const freelancerColumns = [
				'id',
				'name',
				'location',
				'hourly_rate',
				'is_available',
				'portfolio',
				'skills',
			];

			const freelancerValuePlaceholders = [];
			const freelancerValues = [];

			// Get user IDs for freelancers (first numFreelancers users)
			const freelancerUserIds = userResult.rows
				.filter((row) => row.user_type === 'freelancer')
				.map((row) => row.id);

			freelancerProfiles.forEach((profile, idx) => {
				const baseIdx = idx * freelancerColumns.length;
				freelancerValuePlaceholders.push(
					`(${freelancerColumns
						.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
						.join(', ')})`
				);
				freelancerValues.push(
					freelancerUserIds[idx],
					profile.name,
					profile.location,
					profile.hourly_rate,
					profile.is_available,
					JSON.stringify(profile.portfolio),
					JSON.stringify(profile.skills) // Store skill names in JSONB for fast lookup
				);
			});

			const freelancerQuery = `
				INSERT INTO freelancer_profiles (${freelancerColumns.join(', ')})
				VALUES ${freelancerValuePlaceholders.join(',\n')}
			`;

			await dbClient.query(freelancerQuery, freelancerValues);
			console.log(`Inserted ${freelancerProfiles.length} freelancer profiles`);

			// 3. Insert freelancer_skills relationships
			console.log('🔗 Creating freelancer-skill relationships...');

			// Get skill IDs from the skills table
			const skillResult = await dbClient.query('SELECT id, name FROM skills');
			const skillMap = new Map(
				skillResult.rows.map((row) => [row.name, row.id])
			);

			const freelancerSkillColumns = ['freelancer_id', 'skill_id'];
			const freelancerSkillValuePlaceholders = [];
			const freelancerSkillValues = [];
			let skillValueIndex = 1;

			freelancerProfiles.forEach((profile, profileIdx) => {
				const freelancerId = freelancerUserIds[profileIdx];

				profile.skills.forEach((skillName) => {
					const skillId = skillMap.get(skillName);
					if (skillId) {
						freelancerSkillValuePlaceholders.push(
							`($${skillValueIndex}, $${skillValueIndex + 1})`
						);
						freelancerSkillValues.push(freelancerId, skillId);
						skillValueIndex += 2;
					}
				});
			});

			if (freelancerSkillValuePlaceholders.length > 0) {
				const freelancerSkillQuery = `
					INSERT INTO freelancer_skills (${freelancerSkillColumns.join(', ')})
					VALUES ${freelancerSkillValuePlaceholders.join(',\n')}
					ON CONFLICT (freelancer_id, skill_id) DO NOTHING
				`;

				await dbClient.query(freelancerSkillQuery, freelancerSkillValues);
				console.log(
					`✅ Created ${freelancerSkillValuePlaceholders.length} freelancer-skill relationships`
				);
			}
		}

		// 4. Insert client profiles
		if (clientProfiles.length > 0) {
			const clientColumns = [
				'id',
				'company_name',
				'description',
				'location',
				'contact_info',
			];

			const clientValuePlaceholders = [];
			const clientValues = [];

			// Get user IDs for clients (remaining users)
			const clientUserIds = userResult.rows
				.filter((row) => row.user_type === 'client')
				.map((row) => row.id);

			clientProfiles.forEach((profile, idx) => {
				const baseIdx = idx * clientColumns.length;
				clientValuePlaceholders.push(
					`(${clientColumns
						.map((_, colIdx) => `$${baseIdx + colIdx + 1}`)
						.join(', ')})`
				);
				clientValues.push(
					clientUserIds[idx],
					profile.company_name,
					profile.description,
					profile.location,
					JSON.stringify(profile.contact_info)
				);
			});

			const clientQuery = `
				INSERT INTO client_profiles (${clientColumns.join(', ')})
				VALUES ${clientValuePlaceholders.join(',\n')}
			`;

			await dbClient.query(clientQuery, clientValues);
			console.log(`Inserted ${clientProfiles.length} client profiles`);
		}

		// Commit transaction
		await dbClient.query('COMMIT');
		console.log('✅ Successfully seeded users with profiles and skills!');
	} catch (error) {
		// Rollback on error
		await dbClient.query('ROLLBACK');
		console.error('❌ Error seeding users:', error);
		throw error;
	}
}

// Updated verification function
export async function verifySeeding() {
	try {
		const userCount = await dbClient.query('SELECT COUNT(*) FROM users');
		const freelancerCount = await dbClient.query(
			'SELECT COUNT(*) FROM freelancer_profiles'
		);
		const clientCount = await dbClient.query(
			'SELECT COUNT(*) FROM client_profiles'
		);
		const skillCount = await dbClient.query('SELECT COUNT(*) FROM skills');
		const freelancerSkillCount = await dbClient.query(
			'SELECT COUNT(*) FROM freelancer_skills'
		);

		console.log('📊 Seeding Verification:');
		console.log(`Total users: ${userCount.rows[0].count}`);
		console.log(`Freelancer profiles: ${freelancerCount.rows[0].count}`);
		console.log(`Client profiles: ${clientCount.rows[0].count}`);
		console.log(`Skills: ${skillCount.rows[0].count}`);
		console.log(
			`Freelancer-skill relationships: ${freelancerSkillCount.rows[0].count}`
		);

		// Verify relationships
		const orphanedProfiles = await dbClient.query(`
			SELECT 'freelancer' as type, fp.id 
			FROM freelancer_profiles fp 
			LEFT JOIN users u ON fp.id = u.id 
			WHERE u.id IS NULL
			UNION ALL
			SELECT 'client' as type, cp.id 
			FROM client_profiles cp 
			LEFT JOIN users u ON cp.id = u.id 
			WHERE u.id IS NULL
		`);

		if (orphanedProfiles.rows.length > 0) {
			console.log(
				'⚠️  Warning: Found orphaned profiles:',
				orphanedProfiles.rows
			);
		} else {
			console.log('✅ All profiles have valid user relationships');
		}

		// Verify skill relationships
		const orphanedSkillRelations = await dbClient.query(`
			SELECT 'freelancer_skill' as type, fs.freelancer_id, fs.skill_id
			FROM freelancer_skills fs 
			LEFT JOIN users u ON fs.freelancer_id = u.id 
			LEFT JOIN skills s ON fs.skill_id = s.id
			WHERE u.id IS NULL OR s.id IS NULL
		`);

		if (orphanedSkillRelations.rows.length > 0) {
			console.log(
				'⚠️  Warning: Found orphaned skill relationships:',
				orphanedSkillRelations.rows
			);
		} else {
			console.log('✅ All skill relationships are valid');
		}
	} catch (error) {
		console.error('❌ Error verifying seeding:', error);
	}
}
