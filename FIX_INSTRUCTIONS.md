# Xatolarni tuzatish bo'yicha ko'rsatma

## 1-xato: Enum katta harf muammosi (INCOME vs income)

### Sabab:
SQLAlchemy Python enum nomini (.name = "INCOME") PostgreSQL ga yubormoqdi,
qiymat o'rniga (.value = "income"). Tuzatildi: `values_callable` qo'shildi.

### Agar jadvallar allaqachon yaratilgan bo'lsa:
```bash
# Docker container ichida SQL ishga tushirish:
docker exec -i <container_nomi_db> psql -U postgres -d maxplast_db < fix_driver_enum.sql
```

---

## 2-xato: Container nomi

### Container nomini topish:
```bash
docker ps
```
Chiqadigan ro'yxatdan o'zingizning container nomini toping.
Odatda quyidagilardan biri bo'ladi:
- maxplast-api-1
- maxplast_api
- maxplast-api

### Migratsiya buyrug'i (to'g'ri):
```bash
# Avval container nomini aniqlang:
docker ps --format "table {{.Names}}"

# Keyin migratsiya:
docker exec <API_CONTAINER_NOMI> alembic upgrade head

# Misol:
docker exec maxplast-api-1 alembic upgrade head
```

### Agar migratsiya allaqachon 008 gacha o'tgan bo'lsa (noto'g'ri enum bilan):

**1-usul: SQL fix skripti:**
```bash
docker exec -i <DB_CONTAINER_NOMI> psql -U postgres -d maxplast_db < fix_driver_enum.sql
```

**2-usul: Qo'lda:**
```bash
# DB containerga kiring
docker exec -it <DB_CONTAINER_NOMI> psql -U postgres -d maxplast_db

# Keyin SQL ni kiriting:
ALTER TABLE driver_transactions ALTER COLUMN transaction_type TYPE VARCHAR(20);
DROP TYPE IF EXISTS drivertransactiontype;
CREATE TYPE drivertransactiontype AS ENUM ('income', 'expense', 'salary');
ALTER TABLE driver_transactions
    ALTER COLUMN transaction_type TYPE drivertransactiontype
    USING lower(transaction_type)::drivertransactiontype;
\q
```

**3-usul: Jadvallarni o'chirib qayta yaratish (ma'lumot yo'q bo'lsa):**
```bash
docker exec -it <DB_CONTAINER_NOMI> psql -U postgres -d maxplast_db

# Jadvallarni o'chirish:
DROP TABLE IF EXISTS driver_monthly_salaries CASCADE;
DROP TABLE IF EXISTS driver_transactions CASCADE;
DROP TABLE IF EXISTS driver_expense_categories CASCADE;
DROP TABLE IF EXISTS driver_income_categories CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TYPE IF EXISTS drivertransactiontype;
\q

# Alembic versiyasini 007 ga qaytarish:
docker exec <API_CONTAINER_NOMI> alembic downgrade 007_add_default_per_piece

# Qayta migratsiya:
docker exec <API_CONTAINER_NOMI> alembic upgrade head
```

---

## To'liq qayta ishga tushirish (eng oson yo'l):

```bash
# Barcha containerlarni to'xtating
docker-compose down

# Yangi fayllarni qo'ying, keyin:
docker-compose up -d

# API container nomi aniqlang:
docker ps --format "table {{.Names}}"

# Migratsiya:
docker exec maxplast-api-1 alembic upgrade head
```
