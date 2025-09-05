import { PrismaClient } from '@prisma/client';
import { ALL_CHAINS } from '@satoshi-hub/sdk';

const prisma = new PrismaClient();

async function main() {
  console.log(`Start seeding ...`);

  for (const chain of ALL_CHAINS) {
    const createdChain = await prisma.chain.upsert({
      where: { chainId: chain.id },
      update: {
        name: chain.name,
      },
      create: {
        id: chain.id,
        chainId: chain.id,
        name: chain.name,
        isEvm: chain.isEvm,
      },
    });
    console.log(`Created or updated chain: ${createdChain.name} (ID: ${createdChain.chainId})`);
  }

  console.log(`Seeding finished.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
