-- Esquema y datos iniciales de la tienda. PostgreSQL lo ejecuta una sola vez,
-- cuando el volumen de datos está vacío (docker-entrypoint-initdb.d).

CREATE TABLE categories (
    id   serial PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE products (
    id          serial PRIMARY KEY,
    name        text           NOT NULL,
    description text           NOT NULL,
    price       numeric(10, 2) NOT NULL CHECK (price > 0),
    stock       integer        NOT NULL CHECK (stock >= 0),
    category_id integer        NOT NULL REFERENCES categories (id)
);

CREATE TABLE orders (
    id         bigserial PRIMARY KEY,
    email      text           NOT NULL,
    total      numeric(12, 2) NOT NULL,
    status     text           NOT NULL CHECK (status IN ('paid', 'payment_failed')),
    created_at timestamptz    NOT NULL DEFAULT now()
);

CREATE TABLE order_items (
    id         bigserial PRIMARY KEY,
    order_id   bigint         NOT NULL REFERENCES orders (id),
    product_id integer        NOT NULL,
    quantity   integer        NOT NULL CHECK (quantity > 0),
    price      numeric(10, 2) NOT NULL
);

INSERT INTO categories (name) VALUES
    ('Café'), ('Té'), ('Cacao'), ('Tazas'), ('Molinos'), ('Cafeteras'), ('Filtros'), ('Termos');

-- 500 productos deterministas: mismo catálogo en cada máquina.
-- Stock alto para que el tráfico de fondo no lo agote en días.
INSERT INTO products (name, description, price, stock, category_id)
SELECT
    (ARRAY['Café', 'Té', 'Cacao', 'Taza', 'Molino', 'Cafetera', 'Filtro', 'Termo'])[1 + i % 8]
        || ' ' || (ARRAY['clásico', 'orgánico', 'premium', 'de origen', 'artesanal'])[1 + i % 5]
        || ' ' || i,
    'Producto ' || (ARRAY['ligero', 'intenso', 'equilibrado', 'aromático'])[1 + i % 4]
        || ' seleccionado para la tienda, lote ' || (1000 + i),
    5 + (i * 37 % 9500) / 100.0,
    1000000,
    1 + i % 8
FROM generate_series(1, 500) AS i;
