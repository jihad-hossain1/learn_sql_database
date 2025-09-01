-- 1.1 Create a table with a JSONB column
CREATE TABLE products (
  id    SERIAL PRIMARY KEY,
  name  TEXT       NOT NULL,
  specs JSONB      NOT NULL
);

-- 1.2 Insert JSON documents
INSERT INTO products (name, specs) VALUES
  ('Smartphone', 
   '{
      "brand": "Acme",
      "model": "X200",
      "dimensions": { "width": 70, "height": 150, "depth": 8 },
      "features": ["4G", "Bluetooth", "WiFi"],
      "warranty": "2 years"
    }'),
  ('Laptop',
   '{
      "brand": "Beta",
      "model": "BookPro",
      "dimensions": { "width": 320, "height": 220, "depth": 18 },
      "features": ["WiFi", "SSD", "Backlit Keyboard"],
      "warranty": "1 year"
    }'),
    ('Tablet',
     '{
        "brand": "Gamma",
        "model": "TabPro",
        "dimensions": { "width": 200, "height": 120, "depth": 10 },
        "features": ["4G", "Bluetooth", "WiFi"],
        "warranty": "2 years"
      }'),
      ('Smartwatch',
       '{
          "brand": "Delta",
          "model": "WatchPro",
          "dimensions": { "width": 40, "height": 40, "depth": 12 },
          "features": ["4G", "Bluetooth", "WiFi"],
          "warranty": "2 years"
        }');


-- ->	Get JSON object at key	JSON/JSONB
-- ->>	Get text value at key	TEXT
-- #>	Get JSON object at path array	JSON/JSONB
-- #>>	Get text value at path array	TEXT
-- @>	Does left JSON contain right JSON	BOOLEAN
-- ?	Does JSON object have key	BOOLEAN
-- ?		Do any of these keys exist
-- ?&	Do all of these keys exist	BOOLEAN
-- -	Remove key	JSONB
-- #-	Remove key or index at path	JSONB


-- Extracting JSON Values
SELECT 
	specs->>'brand' AS BRAND, -- top level text
	specs->'features' AS features, -- top level object or array
	specs->'dimensions' AS dimensions, -- top level object or array
	specs#>'{dimensions,width}' AS width, -- Nested path
	specs#>>'{dimensions, height}' AS height -- Nested path as text
FROM products;


-- Filtering Rows by JSON Content
SELECT * FROM products
WHERE specs->>'warranty' = '2 years';

-- contains operator
SELECT * FROM products
WHERE specs@> '{"brand":"Acme"}';

-- Existence of a key
SELECT * FROM products
WHERE specs ? 'features';

-- Existence in array
SELECT * FROM products
WHERE specs->'features' ? 'Wifi';



-- Modifying JSON Docs

-- Set or update a key (add battery feature)
UPDATE products
SET specs = jsonb_set(
	specs,
	'{features}',
	(specs->'features') || '"Battery"',
	false
)
WHERE id = 1;

-- Change a nested value (update depth)
UPDATE products
SET specs = jsonb_set(
	specs,
	'{dimensions,depth}',
	'12',
	false
)
WHERE id = 2;

-- Add a new key | merging two json docs
UPDATE products
SET specs = specs || '{"price": 1200}'
WHERE id = 1;

UPDATE products
SET specs = specs || '{"color": "red"}'

-- remove a key
UPDATE products
SET specs = specs - 'color'
WHERE id = 2;

-- remove a nested key
UPDATE products
SET specs = specs #- '{dimensions,depth}'
WHERE id = 2;

SELECT * FROM products;


-- JSON ARRAY

-- Expand array elements in to rows
SELECT 
	id,
	jsonb_array_elements(specs->'features') AS features
FROM products;

-- Aggregate back to JSON array
SELECT jsonb_agg(features) AS all_features
FROM (
	SELECT jsonb_array_elements(specs->'features') AS features
	FROM products
) AS sub;

-- Build JSON objects / array on the fly
SELECT
	jsonb_build_object(
		'id', p.id,
		'name', p.name,
		'brand', p.specs->>'brand'
	) AS summary
FROM products p;

-- Convert a SQL row to JSON
SELECT to_jsonb(p) AS full_record
FROM products p;