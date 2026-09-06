const { Client } = require('pg');
require('dotenv').config();

const connectionString = process.env.DIRECT_URL || process.env.DATABASE_URL;

async function disableRls() {
  const client = new Client({ connectionString, ssl: { rejectUnauthorized: false } });
  try {
    await client.connect();
    console.log('🔌 Connected to Supabase PostgreSQL database...');

    const tables = [
      'Category',
      'User',
      'Video',
      'EBook',
      'Publication',
      'Series',
      'Class',
      'Subject',
      'Payment',
      'Subscription',
      'Donation',
    ];

    for (const table of tables) {
      try {
        await client.query(`ALTER TABLE "${table}" DISABLE ROW LEVEL SECURITY;`);
        console.log(`✅ Disabled RLS on table "${table}"`);
      } catch (err) {
        console.warn(`⚠️ Warning for table "${table}": ${err.message}`);
      }
    }

    console.log('🎉 RLS disabled across all Supabase tables successfully!');
  } catch (err) {
    console.error('❌ Database connection error:', err);
  } finally {
    await client.end();
  }
}

disableRls();
