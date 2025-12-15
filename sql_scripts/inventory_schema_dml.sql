
-- 1. Insert 500 customers
INSERT INTO customers (full_name, email, phone, shipping_address) VALUES
('Emma Kabu', 'emma.kabu@email.com', '+233245678901', '123 Main St, Accra, AC'),
('Emma Kusi', 'emma.kusi@email.com', '+233245678902', '456 Oak Ave, Kumasi, AK'),
('Kofi Brown', 'kofi.brown@email.com', '+233245678903', '789 Pine Rd, Takoradi, TA'),
('Sarah Dwommoh', 'sarah.dwommoh@email.com', '+233245678904', '321 Elm St, Sunyani, AB'),
('Robert Awuni', 'robert.awuni@email.com', '+233245678905', '654 Maple Dr, Tamale, TL'),
('James Kwame', 'james.kwame@email.com', '+233245678906', '987 Birch Ln, Ho, HO'),
('Patricia Dankwah', 'patricia.dankwah@email.com', '+233245678907', '159 Cedar Blvd, Obuasi, AK'),
('Jennifer Naah', 'jennifer.naah@email.com', '+233245678908', '753 Kuwa Way, Spintex, AC'),
('William Abugri', 'william.abugri@email.com', '+233245678909', '951 Aspen Ct, Walewale, WA'),
('Linda Amonu', 'linda.amonu@email.com', '+233245678910', '258 Kuffour Rd, Sagnarigu, TL');

-- Generate remaining 490 customers with UNIQUE full names
INSERT INTO customers (full_name, email, phone, shipping_address)
WITH RECURSIVE unique_names AS (
    -- Start with first names and last names
    SELECT 
        first_name,
        last_name,
        ROW_NUMBER() OVER () as rn
    FROM (
        SELECT unnest(ARRAY[
            'Patrick', 'Ann', 'Emmanuel', 'Lydia', 'Lawson', 'Samuel', 'Prince', 'Abraham',
            'Kwabena', 'Austin', 'Patience', 'Thienry', 'Angela', 'Bernice', 'Amanda', 'Beatrice',
            'Catherine', 'Evelyn', 'Felicity', 'Gloria', 'Hannah', 'Irene', 'Josephine', 'Katherine',
            'John', 'Mary', 'Michael', 'Patricia', 'David', 'Linda', 'Richard', 'Susan',
            'Daniel', 'Margaret', 'Mark', 'Dorothy', 'Paul', 'Grace', 'Stephen', 'Joyce',
            'Andrew', 'Deborah', 'Joshua', 'Ruth', 'Peter', 'Esther', 'Timothy', 'Martha',
            'Simon', 'Naomi', 'Philip', 'Rebecca', 'Nathaniel', 'Rachel', 'Thomas', 'Sarah'
        ]) as first_name
    ) f
    CROSS JOIN (
        SELECT unnest(ARRAY[
            'Mensah', 'Appiah', 'Darko', 'Osei', 'Agyei', 'Boateng', 'Asare', 'Owusu',
            'Adu', 'Amoah', 'Arthur', 'Baah', 'Baffoe', 'Bonsu', 'Dankwah', 'Frimpong',
            'Gyamfi', 'Kwarteng', 'Nkrumah', 'Opoku', 'Quaye', 'Sarpong', 'Tweneboah', 'Yeboah',
            'Adjei', 'Agyapong', 'Ankomah', 'Asante', 'Boakye', 'Danso', 'Fosu', 'Kumi',
            'Manu', 'Nti', 'Ofori', 'Poku', 'Safo', 'Tandoh', 'Wiredu', 'Zanu',
            'Acquah', 'Addae', 'Agyeman', 'Akoto', 'Amankwa', 'Anane', 'Ansah', 'Antwi',
            'Asiamah', 'Atiemo', 'Bediako', 'Buadi', 'Dadzie', 'Donkor', 'Fianko', 'Gyasi'
        ]) as last_name
    ) l
    WHERE first_name || ' ' || last_name NOT IN (
        'Emma Kabu', 'Emma Kusi', 'Kofi Brown', 'Sarah Dwommoh', 'Robert Awuni',
        'James Kwame', 'Patricia Dankwah', 'Jennifer Naah', 'William Abugri', 'Linda Amonu'
    )
    ORDER BY RANDOM()
),
city_data AS (
    SELECT city, region, ROW_NUMBER() OVER () as city_rn
    FROM (VALUES 
        ('Accra', 'AC'), ('Kumasi', 'AK'), ('Takoradi', 'TA'), ('Sunyani', 'AB'),
        ('Tamale', 'TL'), ('Ho', 'HO'), ('Obuasi', 'AK'), ('Spintex', 'AC'),
        ('Walewale', 'WA'), ('Sagnarigu', 'TL'), ('Cape Coast', 'CC'), ('Tema', 'AC'),
        ('Koforidua', 'ER'), ('Techiman', 'BA'), ('Nkawkaw', 'ER'), ('Wa', 'UW'),
        ('Bolgatanga', 'UE'), ('Elmina', 'CC'), ('Winneba', 'CE'), ('Axim', 'WR')
    ) AS c(city, region)
),
numbered_names AS (
    SELECT 
        first_name,
        last_name,
        ROW_NUMBER() OVER () as seq_num
    FROM unique_names
    LIMIT 490  -- Take exactly 490 unique names
)
SELECT 
    nn.first_name || ' ' || nn.last_name,
    nn.first_name || '.' || nn.last_name || '@ghana.com',
    '+233' || LPAD(CAST(FLOOR(RANDOM() * 900000000 + 200000000) AS TEXT), 9, '0'),
    (nn.seq_num % 1000 + 1) || ' ' || 
    CASE (nn.seq_num % 5) 
        WHEN 0 THEN 'Main St' 
        WHEN 1 THEN 'Oak Ave' 
        WHEN 2 THEN 'Pine Rd' 
        WHEN 3 THEN 'Elm St' 
        ELSE 'Maple Dr' 
    END || ', ' ||
    cd.city || ', ' || cd.region
FROM numbered_names nn
CROSS JOIN LATERAL (
    SELECT city, region 
    FROM city_data 
    ORDER BY RANDOM() 
    LIMIT 1
) cd;
-- 2. Insert 500 products

-- Reset the sequence if needed
SELECT setval('products_product_id_seq', 15, true);

-- 2. Generate 500 unique products with guaranteed unique names
WITH RECURSIVE product_categories AS (
    SELECT category, base_name, ROW_NUMBER() OVER () as rn
    FROM (VALUES 
        ('Electronics', 'Smartphone'),
        ('Electronics', 'Camera'),
        ('Electronics', 'TV'),
        ('Electronics', 'Printer'),
        ('Electronics', 'Broadband Modem'),
        ('Electronics', 'Smart Speaker'),
        ('Electronics', 'Gaming Console'),
        ('Electronics', 'Smartwatch'),
        ('Electronics', 'Laptop'),
        ('Electronics', 'Tablet'),
        ('Electronics', 'Smartwatch'),
        ('Electronics', 'Headphones'),
        ('Electronics', 'Speaker'),
        ('Electronics', 'Monitor'),
        ('Electronics', 'Keyboard'),
        ('Electronics', 'Mouse'),
        ('Electronics', 'Router'),
        ('Electronics', 'External Hard Drive'),
        ('Electronics', 'USB Flash Drive'),
        ('Electronics', 'Webcam'),
        ('Clothing', 'Trousers'),
        ('Clothing', 'Shirt'),
        ('Clothing', 'Pants'),
        ('Clothing', 'Skirt'),
        ('Clothing', 'Sweater'),
        ('Clothing', 'Coat'),
        ('Clothing', 'Blouse'),
        ('Clothing', 'T-Shirt'),
        ('Clothing', 'Jeans'),
        ('Clothing', 'Dress'),
        ('Clothing', 'Jacket'),
        ('Clothing', 'Shoes'),
        ('Clothing', 'Hat'),
        ('Clothing', 'Socks'),
        ('Clothing', 'Shorts'),
        ('Clothing', 'Sweater'),
        ('Clothing', 'Coat'),
        ('Clothing', 'Blouse'),
        ('Clothing', 'T-Shirt'),
        ('Clothing', 'Jeans'),
        ('Clothing', 'Dress'),
        ('Clothing', 'Hat'),
        ('Home & Kitchen', 'Blender'),
        ('Home & Kitchen', 'Toaster'),
        ('Home & Kitchen', 'Microwave'),
        ('Home & Kitchen', 'Cookware'),
        ('Home & Kitchen', 'Cutlery'),
        ('Home & Kitchen', 'Tableware'),
        ('Home & Kitchen', 'Furniture'),
        ('Home & Kitchen', 'Lighting'),
        ('Home & Kitchen', 'Decor'),
        ('Home & Kitchen', 'Storage'),
        ('Home & Kitchen', 'Appliance'),
        ('Home & Kitchen', 'Vacuum Cleaner'),
        ('Home & Kitchen', 'Air Purifier'),
        ('Home & Kitchen', 'Coffee Maker'),
        ('Home & Kitchen', 'Dishwasher'),
        ('Home & Kitchen', 'Refrigerator'),
        ('Home & Kitchen', 'Washing Machine'),
        ('Home & Kitchen', 'Dryer'),
        ('Home & Kitchen', 'Oven'),
        ('Home & Kitchen', 'Stove'),
        ('Home & Kitchen', 'Mixer'),
        ('Books', 'Fiction'),
        ('Books', 'Non-Fiction'),
        ('Books', 'Science'),
        ('Books', 'History'),
        ('Books', 'Biography'),
        ('Books', 'Cookbook'),
        ('Books', 'Children'),
        ('Books', 'Mystery'),
        ('Books', 'Romance'),
        ('Books', 'Horror'),
        ('Books', 'Science Fiction'),
        ('Books', 'Fantasy'),
        ('Books', 'Poetry'),
        ('Books', 'Comics'),
        ('Books', 'Graphic Novel'),
        ('Books', 'Travel Guide'),
        ('Books', 'Self-Help'),
        ('Books', 'Health'),
        ('Books', 'Education'),
        ('Books', 'Religion'),
        ('Books', 'Philosophy'),
        ('Books', 'Politics'),
        ('Books', 'Business'),
        ('Books', 'Art'),
        ('Books', 'Travel'),
        ('books ', 'Self-Help'),
        ('books ', 'Fantasy'),
        ('Sports', 'Football'),
        ('Sports', 'Cricket Bat'),
        ('Sports', 'Volleyball'),
        ('Sports', 'Badminton Racket'),
        ('Sports', 'Tennis Racket'),
        ('Sports', 'Yoga Mat'),
        ('Sports', 'Basketball'),
        ('Sports', 'Running Shoes'),
        ('Sports', 'Dumbbells'),
        ('Sports', 'Soccer Ball'),
        ('Sports', 'Golf Clubs'),
        ('Sports', 'Swim Gear'),
        ('Sports', 'Cycling Helmet'),
        ('Sports', 'Fitness Tracker'),
        ('Jewelry', 'Gold Ring'),
        ('Jewelry', 'Gold Necklace'),
        ('Jewelry', 'Gold Earrings'),
        ('Jewelry', 'Silver Bracelet'),
        ('Jewelry', 'Diamond Pendant'),
        ('Jewelry', 'Pearl Necklace'),
        ('Jewelry', 'Sapphire Ring'),
        ('Jewelry', 'Ruby Earrings'),
        ('Jewelry', 'Platinum Band'),
        ('Jewelry', 'Cufflinks'),
        ('Jewelry', 'Charm Bracelet'),
        ('Jewelry', 'Anklet'),
        ('Jewelry', 'Brooch'),
        ('Jewelry', 'Tiara'),
        ('Jewelry', 'Choker'),
        ('Jewelry', 'Locket'),
        ('Jewelry', 'Engagement Ring'),
        ('Jewelry', 'Wedding Band'),
        ('Jewelry', 'Titanium Watch'),
        ('Toys', 'Building Blocks'),
        ('Toys', 'Doll Set'),
        ('Toys', 'Puzzle'),
        ('Toys', 'Remote Car'),
        ('Toys', 'Board Game'),
        ('Toys', 'Action Figure'),
        ('Toys', 'Stuffed Animal'),
        ('Toys', 'Educational Kit'),
        ('Toys', 'LEGO Set'),
        ('Toys', 'Play Kitchen'),
        ('Beauty', 'Skincare Set'),
        ('Beauty', 'Makeup Kit'),
        ('Beauty', 'Perfume'),
        ('Beauty', 'Hair Care'),
        ('Beauty', 'Body Lotion'),
        ('Beauty', 'Face Serum'),
        ('Beauty', 'Lipstick Set'),
        ('Beauty', 'Nail Polish'),
        ('Beauty', 'Face Mask'),
        ('Beauty', 'Sunscreen'),
        ('Beauty', 'Shampoo'),
        ('Beauty', 'Conditioner'),
        ('Beauty', 'Hair Dryer'),
        ('Beauty', 'Curling Iron'),
        ('Beauty', 'Straightener'),
        ('Beauty', 'Makeup Brushes'),
        ('Beauty', 'Facial Cleanser'),
        ('Beauty', 'Toner'),
        ('Beauty', 'Exfoliator'),
        ('Beauty', 'Body Scrub'),
        ('Automotive', 'Car Mat'),
        ('Automotive', 'Air Freshener'),
        ('Automotive', 'Tool Kit'),
        ('Automotive', 'Seat Cover'),
        ('Automotive', 'Steering Wheel Cover'),
        ('Automotive', 'Floor Mats'),
        ('Automotive', 'Car Battery'),
        ('Automotive', 'Headlight Bulb'),
        ('Automotive', 'Tail Light'),
        ('Automotive', 'Turn Signal'),
        ('Automotive', 'Brake Pads'),
        ('Automotive', 'Clutch Kit'),
        ('Automotive', 'Fuel Pump'),
        ('Automotive', 'Radiator'),
        ('Automotive', 'Exhaust System'),
        ('Automotive', 'Suspension Kit'),
        ('Automotive', 'Shock Absorber'),
        ('Automotive', 'Wheel Alignment Kit'),
        ('Automotive', 'Tire Pressure Gauge'),
        ('Automotive', 'Car Jack'),
        ('Automotive', 'Lug Wrench'),
        ('Automotive', 'Car Cover'),
        ('Automotive', 'GPS Holder'),
        ('Automotive', 'Phone Mount'),
        ('Automotive', 'Jump Starter'),
        ('Automotive', 'Tire Inflator'),
        ('Automotive', 'Car Wash Kit'),
        ('Automotive', 'Oil Filter'),
        ('Grocery', 'Organic Coffee'),
        ('Grocery', 'Green Tea'),
        ('Grocery', 'Snack Mix'),
        ('Grocery', 'Pasta'),
        ('Grocery', 'Olive Oil'),
        ('Grocery', 'Honey'),
        ('Grocery', 'Cereal'),
        ('Grocery', 'Chocolate'),
        ('Grocery', 'Jam'),
        ('Grocery', 'Spices'),
        ('Grocery', 'Rice'),
        ('Grocery', 'Flour'),
        ('Grocery', 'Sugar'),
        ('Grocery', 'Salt'),
        ('Grocery', 'Vinegar'),
        ('Grocery', 'Peanut Butter'),
        ('Grocery', 'Canned Beans'),
        ('Grocery', 'Canned Tuna'),
        ('Grocery', 'Soup Mix'),
        ('Grocery', 'Cooking Spray'),
        ('Grocery', 'Dried Fruit'),
        ('Grocery', 'Nuts'),
        ('Grocery', 'Granola Bars'),
        ('Grocery', 'Energy Drink'),
        ('Grocery', 'Fruit Juice'),
        ('Grocery', 'Vegetable Chips'),
        ('Grocery', 'Protein Powder'),
        ('Grocery', 'Meal Replacement Shake'),
        ('Grocery', 'Instant Noodles'),
        ('Grocery', 'Popcorn'),
        ('Grocery', 'Trail Mix'),
        ('Grocery', 'Coconut Water')


    ) AS cat(category, base_name)
),
number_series AS (
    SELECT generate_series(1, 500) as n
),
product_generator AS (
    SELECT 
        n,
        pc.category,
        pc.base_name,
        -- Create UNIQUE product name by adding variant information
        CASE pc.category
            WHEN 'Electronics' THEN 
                pc.base_name || ' ' || 
                CASE (n % 5)
                    WHEN 0 THEN 'Pro'
                    WHEN 1 THEN 'Elite'
                    WHEN 2 THEN 'Ultra'
                    WHEN 3 THEN 'Premium'
                    ELSE 'Advanced'
                END || ' ' ||
                'Model ' || CHR(65 + ((n-1) % 26)) || (n % 100)
            WHEN 'Clothing' THEN
                pc.base_name || ' - ' ||
                CASE (n % 4)
                    WHEN 0 THEN 'Cotton'
                    WHEN 1 THEN 'Wool'
                    WHEN 2 THEN 'Silk'
                    ELSE 'Linen'
                END || ' ' ||
                'Size ' || CHR(65 + ((n-1) % 6))
            WHEN 'Jewelry' THEN
                CASE pc.base_name
                    WHEN 'Gold Ring' THEN 
                        CASE (n % 6)
                            WHEN 0 THEN 'Classic Wedding Band'
                            WHEN 1 THEN 'Diamond Engagement Ring'
                            WHEN 2 THEN 'Signet Ring'
                            WHEN 3 THEN 'Stackable Ring'
                            WHEN 4 THEN 'Eternity Ring'
                            ELSE 'Statement Ring'
                        END || ' - 18K Gold'
                    WHEN 'Gold Necklace' THEN
                        CASE (n % 5)
                            WHEN 0 THEN 'Choker Necklace'
                            WHEN 1 THEN 'Pendant Necklace'
                            WHEN 2 THEN 'Chain Necklace'
                            WHEN 3 THEN 'Lariat Necklace'
                            ELSE 'Bib Necklace'
                        END || ' - 24K Gold'
                    WHEN 'Gold Earrings' THEN
                        CASE (n % 4)
                            WHEN 0 THEN 'Stud Earrings'
                            WHEN 1 THEN 'Hoop Earrings'
                            WHEN 2 THEN 'Drop Earrings'
                            WHEN 3 THEN 'Dangle Earrings'
                            ELSE 'Threader Earrings'
                        END || ' - 22K Gold'
                    ELSE pc.base_name || ' - Design ' || CHR(65 + ((n-1) % 26)) || (n % 10)
                END
            WHEN 'Home & Kitchen' THEN
                pc.base_name || ' ' ||
                CASE (n % 4)
                    WHEN 0 THEN 'Professional Series'
                    WHEN 1 THEN 'Home Edition'
                    WHEN 2 THEN 'Compact'
                    ELSE 'Deluxe'
                END || ' ' || (n % 10 + 1)
            ELSE pc.base_name || ' - ' || 
                CASE (n % 4)
                    WHEN 0 THEN 'Premium Quality'
                    WHEN 1 THEN 'Organic'
                    WHEN 2 THEN 'Family Pack'
                    ELSE 'Travel Size'
                END
        END as product_name,
        -- Generate appropriate price based on category
        CASE pc.category
            WHEN 'Electronics' THEN (RANDOM() * 1000 + 100)::DECIMAL(10,2)
            WHEN 'Clothing' THEN (RANDOM() * 200 + 20)::DECIMAL(10,2)
            WHEN 'Home & Kitchen' THEN (RANDOM() * 500 + 50)::DECIMAL(10,2)
            WHEN 'Books' THEN (RANDOM() * 50 + 10)::DECIMAL(10,2)
            WHEN 'Sports' THEN (RANDOM() * 300 + 30)::DECIMAL(10,2)
            WHEN 'Jewelry' THEN (RANDOM() * 2000 + 100)::DECIMAL(10,2)
            WHEN 'Toys' THEN (RANDOM() * 100 + 15)::DECIMAL(10,2)
            WHEN 'Beauty' THEN (RANDOM() * 150 + 20)::DECIMAL(10,2)
            WHEN 'Automotive' THEN (RANDOM() * 200 + 25)::DECIMAL(10,2)
            ELSE (RANDOM() * 50 + 5)::DECIMAL(10,2)  -- Grocery
        END as price
    FROM number_series ns
    JOIN product_categories pc 
     ON pc.rn = ((ns.n - 1) % (SELECT COUNT(*) FROM product_categories)) + 1
)
INSERT INTO products (product_name, product_category, price)
SELECT DISTINCT ON (product_name)  -- This ensures UNIQUE product names
    product_name,
    category,
    price
FROM product_generator
ORDER BY product_name, n  -- DISTINCT ON keeps first occurrence
LIMIT 500;  

-- 3. Insert inventory for all 500 products
INSERT INTO inventory (product_id, quantity_in_stock, last_restocked)
SELECT 
    product_id,
    FLOOR(RANDOM() * 1000)::INT,
    CURRENT_TIMESTAMP - INTERVAL '1 day' * FLOOR(RANDOM() * 90)::INT
FROM products
ORDER BY product_id;

-- 4. Insert 500 orders
INSERT INTO orders (customer_id, order_date, total_order_amount, order_status)
SELECT 
    customer_id,
    CURRENT_TIMESTAMP - INTERVAL '1 day' * FLOOR(RANDOM() * 365)::INT - INTERVAL '1 hour' * FLOOR(RANDOM() * 24)::INT,
    (RANDOM() * 1000 + 10)::DECIMAL(10,2),
    (ARRAY['Pending', 'Shipped', 'Delivered', 'Cancelled'])[1 + FLOOR(RANDOM() * 4)::INT]
FROM customers
ORDER BY RANDOM()
LIMIT 500;

-- 5. Insert order items (multiple items per order)
WITH order_numbers AS (
    SELECT order_id, ROW_NUMBER() OVER () as rn
    FROM orders
)
INSERT INTO order_items (order_id, product_id, quantity, item_price)
SELECT 
    o.order_id,
    p.product_id,
    FLOOR(RANDOM() * 10)::INT + 1,
    p.price
FROM order_numbers o
CROSS JOIN LATERAL (
    SELECT product_id, price 
    FROM products 
    ORDER BY RANDOM() 
    LIMIT (FLOOR(RANDOM() * 5)::INT + 1)
) p;

-- Update orders total_amount based on order_items
UPDATE orders o
SET total_order_amount = (
    SELECT COALESCE(SUM(oi.quantity * oi.item_price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);

-- Let's verify the data counts
SELECT 
    (SELECT COUNT(*) FROM customers) as customer_count,
    (SELECT COUNT(*) FROM products) as product_count,
    (SELECT COUNT(*) FROM inventory) as inventory_count,
    (SELECT COUNT(*) FROM orders) as order_count,
    (SELECT COUNT(*) FROM order_items) as order_item_count;