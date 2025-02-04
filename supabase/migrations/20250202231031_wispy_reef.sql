/*
  # Schéma de base de données pour l'espace client

  1. Tables
    - users: Utilisateurs de l'application
    - buildings: Bâtiments gérés
    - audits: Audits énergétiques
    - documents: Documents liés aux bâtiments
    - subscriptions: Abonnements des utilisateurs

  2. Sécurité
    - RLS activé sur toutes les tables
    - Politiques d'accès basées sur l'authentification
*/

-- Users
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  name text,
  stripe_customer_id text UNIQUE,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own data"
  ON users
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

-- Buildings
CREATE TABLE buildings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id),
  name text NOT NULL,
  type text NOT NULL,
  surface numeric NOT NULL,
  address text,
  status text DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE buildings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own buildings"
  ON buildings
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id);

-- Audits
CREATE TABLE audits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  building_id uuid REFERENCES buildings(id),
  date timestamptz NOT NULL,
  energy_consumption numeric,
  co2_emissions numeric,
  recommendations jsonb,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE audits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read audits for their buildings"
  ON audits
  FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM buildings
    WHERE buildings.id = audits.building_id
    AND buildings.user_id = auth.uid()
  ));

-- Documents
CREATE TABLE documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  building_id uuid REFERENCES buildings(id),
  name text NOT NULL,
  type text NOT NULL,
  url text NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read documents for their buildings"
  ON documents
  FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM buildings
    WHERE buildings.id = documents.building_id
    AND buildings.user_id = auth.uid()
  ));

-- Subscriptions
CREATE TABLE subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id),
  stripe_subscription_id text UNIQUE NOT NULL,
  status text NOT NULL,
  plan text NOT NULL,
  current_period_end timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own subscriptions"
  ON subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);