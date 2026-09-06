const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: './.env' });

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const defaultUsers = [
  {
    name: 'System Administrator',
    email: 'admin@system.com',
    password: 'Admin@12345',
    role: 'ADMIN',
    publicationId: null,
  },
  {
    name: 'Oxford Publication Vendor',
    email: 'vendor@oxford.com',
    password: 'Vendor@12345',
    role: 'PUBLICATION',
    publicationId: null,
  },
  {
    name: 'Rahul Sharma (Student)',
    email: 'student@gmail.com',
    password: 'Student@12345',
    role: 'PUBLIC',
    publicationId: null,
  },
  {
    name: 'Hariom (Student)',
    email: 'hariom.info07@gmail.com',
    password: 'Hariom2005.',
    role: 'PUBLIC',
    publicationId: null,
  },
];

async function seedUsers() {
  console.log('🌱 Seeding default users into Supabase DB...');

  for (const u of defaultUsers) {
    const cleanEmail = u.email.trim().toLowerCase();
    const { data: existing } = await supabase.from('User').select('*').eq('email', cleanEmail).single();

    const hashedPassword = await bcrypt.hash(u.password, 10);

    if (existing) {
      // Update password hash and role
      const { error: updateErr } = await supabase
        .from('User')
        .update({
          password: hashedPassword,
          role: u.role,
          name: u.name,
          publicationId: u.publicationId,
        })
        .eq('email', cleanEmail);

      if (updateErr) {
        console.error(`❌ Error updating ${cleanEmail}:`, updateErr);
      } else {
        console.log(`✅ Updated user in DB: ${cleanEmail}`);
      }
    } else {
      // Insert new user
      const { error: insertErr } = await supabase.from('User').insert([
        {
          name: u.name,
          email: cleanEmail,
          password: hashedPassword,
          role: u.role,
          publicationId: u.publicationId,
        },
      ]);

      if (insertErr) {
        console.error(`❌ Error inserting ${cleanEmail}:`, insertErr);
      } else {
        console.log(`✅ Created user in DB: ${cleanEmail}`);
      }
    }
  }

  console.log('🎉 Default users seeding complete!');
}

seedUsers();
