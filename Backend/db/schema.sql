

-- 1. Suppliers
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id     VARCHAR(20) PRIMARY KEY,        
    supplier_name   VARCHAR(150) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    country         VARCHAR(100) NOT NULL,
    capabilities    VARCHAR(150) NOT NULL,
    supplier_tier   VARCHAR(20) NOT NULL,         
    lead_time_days  INTEGER NOT NULL CHECK (lead_time_days >= 0),
    risk_rating     VARCHAR(20) NOT NULL,         
    certification   VARCHAR(100),
    active_status   VARCHAR(30) NOT NULL,         
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Facilities 
CREATE TABLE IF NOT EXISTS facilities (
    facility_id             VARCHAR(20) PRIMARY KEY, 
    facility_name           VARCHAR(150) NOT NULL,
    facility_type           VARCHAR(50) NOT NULL,  
    city                    VARCHAR(100) NOT NULL,
    country                 VARCHAR(100) NOT NULL,
    capacity_units_per_day  INTEGER CHECK (capacity_units_per_day >= 0),
    storage_capacity_units  INTEGER CHECK (storage_capacity_units >= 0),
    operational_status      VARCHAR(30) NOT NULL,  
    latitude                DOUBLE PRECISION,
    longitude               DOUBLE PRECISION,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Components Master 
CREATE TABLE IF NOT EXISTS components (
    component_id    VARCHAR(20) PRIMARY KEY,         
    part_number     VARCHAR(50) UNIQUE NOT NULL,
    component_name  VARCHAR(150),
    category        VARCHAR(100),
    criticality     VARCHAR(20) DEFAULT 'Medium',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Supplier <-> Component Mapping
CREATE TABLE IF NOT EXISTS supplier_components (
    id                  SERIAL PRIMARY KEY,
    supplier_id         VARCHAR(20) NOT NULL REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    component_id        VARCHAR(20) NOT NULL REFERENCES components(component_id) ON DELETE CASCADE,
    unit_cost_usd       NUMERIC(12, 2) CHECK (unit_cost_usd >= 0),
    is_primary_supplier BOOLEAN DEFAULT TRUE,
    UNIQUE (supplier_id, component_id)
);

-- 5. Products (Mobile / Laptop SKUs)
CREATE TABLE IF NOT EXISTS products (
    sku                     VARCHAR(30) PRIMARY KEY, 
    product_name            VARCHAR(150) NOT NULL,
    product_category        VARCHAR(50) NOT NULL,   
    model_year              INTEGER,
    bom_part_numbers        TEXT NOT NULL,          
    production_location     VARCHAR(20) NOT NULL REFERENCES facilities(facility_id),
    unit_selling_price_usd  NUMERIC(12, 2) CHECK (unit_selling_price_usd >= 0),
    target_daily_production INTEGER CHECK (target_daily_production >= 0),
    lifecycle_status        VARCHAR(30) NOT NULL,   -- Active, Pilot, End of Life
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Bill of Materials 
CREATE TABLE IF NOT EXISTS bom (
    bom_id          SERIAL PRIMARY KEY,
    sku             VARCHAR(30) NOT NULL REFERENCES products(sku) ON DELETE CASCADE,
    component_id    VARCHAR(20) NOT NULL REFERENCES components(component_id) ON DELETE CASCADE,
    qty_per_unit    NUMERIC(10, 4) NOT NULL DEFAULT 1.0 CHECK (qty_per_unit > 0),
    UNIQUE (sku, component_id)
);

-- 7. Inventory Snapshot
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id    SERIAL PRIMARY KEY,
    facility_id     VARCHAR(20) NOT NULL REFERENCES facilities(facility_id) ON DELETE CASCADE,
    component_id    VARCHAR(20) NOT NULL REFERENCES components(component_id) ON DELETE CASCADE,
    on_hand_qty     INTEGER NOT NULL DEFAULT 0 CHECK (on_hand_qty >= 0),
    safety_stock    INTEGER NOT NULL DEFAULT 0 CHECK (safety_stock >= 0),
    buffer_days     INTEGER NOT NULL DEFAULT 0 CHECK (buffer_days >= 0),
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (facility_id, component_id)
);

-- 8. Transport Lanes
CREATE TABLE IF NOT EXISTS transport_lanes (
    lane_id                 SERIAL PRIMARY KEY,
    origin_facility_id      VARCHAR(20) NOT NULL REFERENCES facilities(facility_id),
    destination_facility_id VARCHAR(20) NOT NULL REFERENCES facilities(facility_id),
    transport_mode          VARCHAR(30) NOT NULL,   
    avg_lead_time_days      INTEGER CHECK (avg_lead_time_days >= 0),
    avg_freight_cost_usd    NUMERIC(12, 2) CHECK (avg_freight_cost_usd >= 0),
    UNIQUE (origin_facility_id, destination_facility_id, transport_mode)
);

-- 9. Shipments
CREATE TABLE IF NOT EXISTS shipments (
    shipment_id             VARCHAR(20) PRIMARY KEY,
    supplier_id             VARCHAR(20) NOT NULL REFERENCES suppliers(supplier_id),
    part_number             VARCHAR(50) NOT NULL,
    origin_facility_id      VARCHAR(20) NOT NULL REFERENCES facilities(facility_id),
    destination_facility_id VARCHAR(20) NOT NULL REFERENCES facilities(facility_id),
    transport_mode          VARCHAR(30) NOT NULL,  
    dispatch_date           DATE NOT NULL,
    eta                     DATE NOT NULL,
    shipment_status         VARCHAR(30) NOT NULL,  
    quantity                INTEGER NOT NULL CHECK (quantity >= 0),
    freight_cost_usd        NUMERIC(12, 2) CHECK (freight_cost_usd >= 0),
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Customer Orders
CREATE TABLE IF NOT EXISTS orders (
    order_id                VARCHAR(20) PRIMARY KEY,
    sku                     VARCHAR(30) NOT NULL REFERENCES products(sku),
    quantity                INTEGER NOT NULL CHECK (quantity > 0),
    destination_facility_id VARCHAR(20) NOT NULL REFERENCES facilities(facility_id),
    order_date              DATE NOT NULL,
    required_date           DATE NOT NULL,
    priority                VARCHAR(20) NOT NULL,  
    order_status            VARCHAR(30) NOT NULL,  
    customer_segment        VARCHAR(30) NOT NULL, 
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. External Disruption Events
CREATE TABLE IF NOT EXISTS events (
    event_id                VARCHAR(20) PRIMARY KEY,
    event_type              VARCHAR(60) NOT NULL,  
    event_timestamp         TIMESTAMP NOT NULL,
    location_facility_id    VARCHAR(20) REFERENCES facilities(facility_id),
    city                    VARCHAR(100),
    country                 VARCHAR(100),
    severity                VARCHAR(20) NOT NULL,  
    source                  VARCHAR(100) NOT NULL,
    source_credibility      VARCHAR(20) NOT NULL,  
    raw_event_text          TEXT NOT NULL,
    event_status            VARCHAR(30) NOT NULL,  
    duration_estimate_days  INTEGER CHECK (duration_estimate_days >= 0),
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Graph Dependency Edges (For Propagation & Neo4j Sync)
CREATE TABLE IF NOT EXISTS dependencies (
    dependency_id       SERIAL PRIMARY KEY,
    source_type         VARCHAR(30) NOT NULL,      
    source_id           VARCHAR(50) NOT NULL,
    target_type         VARCHAR(30) NOT NULL,
    target_id           VARCHAR(50) NOT NULL,
    relationship_type   VARCHAR(50) NOT NULL,      
    dependency_weight   NUMERIC(5, 4) DEFAULT 1.0000 CHECK (dependency_weight >= 0 AND dependency_weight <= 1),
    confidence_score    NUMERIC(5, 4) DEFAULT 1.0000 CHECK (confidence_score >= 0 AND confidence_score <= 1),
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (source_type, source_id, target_type, target_id, relationship_type)
);


CREATE INDEX IF NOT EXISTS idx_events_facility ON events(location_facility_id);
CREATE INDEX IF NOT EXISTS idx_events_type_severity ON events(event_type, severity);
CREATE INDEX IF NOT EXISTS idx_shipments_supplier ON shipments(supplier_id);
CREATE INDEX IF NOT EXISTS idx_shipments_part ON shipments(part_number);
CREATE INDEX IF NOT EXISTS idx_shipments_status ON shipments(shipment_status);
CREATE INDEX IF NOT EXISTS idx_orders_sku ON orders(sku);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_dependencies_source ON dependencies(source_type, source_id);
CREATE INDEX IF NOT EXISTS idx_dependencies_target ON dependencies(target_type, target_id);