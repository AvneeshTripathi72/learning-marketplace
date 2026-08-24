"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('🌱 Seeding backend database with dummy data...');
    const pub1 = await prisma.publication.upsert({
        where: { email: 'contact@oxfordpub.com' },
        update: {},
        create: {
            name: 'Oxford Educational Press',
            email: 'contact@oxfordpub.com',
            mobile: '+91 9876543210',
            address: '123 University Road, New Delhi',
            logoUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=150',
            inquiryNumber: '1800-123-4567',
            isActive: true,
        },
    });
    const pub2 = await prisma.publication.upsert({
        where: { email: 'info@pearson.in' },
        update: {},
        create: {
            name: 'Pearson India',
            email: 'info@pearson.in',
            mobile: '+91 9811223344',
            address: '45 Knowledge Park, Gurugram',
            logoUrl: 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=150',
            inquiryNumber: '1800-987-6543',
            isActive: true,
        },
    });
    const user1 = await prisma.user.upsert({
        where: { email: 'user@oxford.com' },
        update: {},
        create: {
            name: 'Oxford Admin User',
            email: 'user@oxford.com',
            password: 'password123',
            role: client_1.UserRole.PUBLICATION,
            publicationId: pub1.id,
        },
    });
    const user2 = await prisma.user.upsert({
        where: { email: 'public@user.com' },
        update: {},
        create: {
            name: 'Rahul Sharma (Student)',
            email: 'public@user.com',
            password: 'password123',
            role: client_1.UserRole.PUBLIC,
        },
    });
    const series1 = await prisma.series.create({
        data: {
            name: 'CBSE 2026 Curriculum',
            publicationId: pub1.id,
            classes: {
                create: [
                    {
                        name: 'Class 10',
                        subjects: {
                            create: [
                                { name: 'Mathematics' },
                                { name: 'Science' },
                                { name: 'English' },
                                { name: 'Social Studies' },
                            ],
                        },
                    },
                ],
            },
        },
    });
    const catEdu = await prisma.category.create({
        data: { name: 'Mathematics & Science', isEnabled: true },
    });
    await prisma.video.create({
        data: {
            url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            platform: client_1.VideoPlatform.YOUTUBE,
            channelName: 'Oxford Academic YouTube',
            categoryId: catEdu.id,
            status: client_1.VideoStatus.APPROVED,
            submittedById: user1.id,
        },
    });
    await prisma.donation.create({
        data: {
            channelName: 'Global Science Academy',
            upiId: 'sciencecreator@upi',
            qrCodeUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=upi://pay?pa=sciencecreator@upi',
            creatorPhotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        },
    });
    console.log('✅ Seeding completed successfully!');
}
main()
    .catch((e) => {
    console.error('❌ Error during seeding:', e);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map