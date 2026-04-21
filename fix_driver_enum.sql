-- Agar driver_transactions jadvali allaqachon yaratilgan bo'lsa
-- va enum qiymatlari noto'g'ri bo'lsa (INCOME o'rniga income kerak),
-- quyidagi buyruqlarni ishga tushiring:

-- 1. Avval joriy enum qiymatlarini ko'ring
SELECT enumlabel FROM pg_enum
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE pg_type.typname = 'drivertransactiontype';

-- 2. Agar INCOME, EXPENSE, SALARY ko'rinsa, quyidagilarni bajaring:

-- Eski ustunga vaqtinchalik text tur bering
ALTER TABLE driver_transactions
    ALTER COLUMN transaction_type TYPE VARCHAR(20);

-- Eski enum typeni o'chirish
DROP TYPE IF EXISTS drivertransactiontype;

-- Yangi to'g'ri enum yaratish (kichik harf)
CREATE TYPE drivertransactiontype AS ENUM ('income', 'expense', 'salary');

-- Ustunni yangi enum typega o'tkazish
ALTER TABLE driver_transactions
    ALTER COLUMN transaction_type TYPE drivertransactiontype
    USING lower(transaction_type)::drivertransactiontype;

-- Natijani tekshirish
SELECT enumlabel FROM pg_enum
JOIN pg_type ON pg_enum.enumtypid = pg_type.oid
WHERE pg_type.typname = 'drivertransactiontype';
-- income, expense, salary ko'rinishi kerak
