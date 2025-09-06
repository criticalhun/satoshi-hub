-- CreateTable
CREATE TABLE "TxJob" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "fromChainId" INTEGER NOT NULL,
    "toChainId" INTEGER NOT NULL,
    "payload" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "result" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
