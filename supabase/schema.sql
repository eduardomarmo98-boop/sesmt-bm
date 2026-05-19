-- ==========================================================
-- SESMT B&M - Schema Supabase (PostgreSQL)
-- ==========================================================
-- Execute este arquivo no SQL Editor do Supabase.
-- Depois execute seed.sql para popular o catálogo.
-- ==========================================================

-- Limpa schema anterior (cuidado em produção!)
DROP TABLE IF EXISTS logs_email CASCADE;
DROP TABLE IF EXISTS documentos CASCADE;
DROP TABLE IF EXISTS maquinas CASCADE;
DROP TABLE IF EXISTS funcionarios CASCADE;
DROP TABLE IF EXISTS empresa_obras CASCADE;
DROP TABLE IF EXISTS empresas CASCADE;
DROP TABLE IF EXISTS obras CASCADE;
DROP TABLE IF EXISTS catalogo_funcoes CASCADE;
DROP TABLE IF EXISTS catalogo_documentos CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;
DROP TABLE IF EXISTS config CASCADE;

-- ==========================================================
-- USUÁRIOS (estende auth.users)
-- ==========================================================
CREATE TABLE usuarios (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  nome TEXT NOT NULL,
  tipo TEXT NOT NULL CHECK (tipo IN ('diretoria','sesmt','coordenador','engenheiro','tst','cliente','visualizador','empresa')),
  empresa_id BIGINT,
  obra_ids BIGINT[] DEFAULT '{}',
  nao_apagar BOOLEAN DEFAULT false,
  criado_em TIMESTAMPTZ DEFAULT now()
);

-- ==========================================================
-- OBRAS
-- ==========================================================
CREATE TABLE obras (
  id BIGSERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  endereco TEXT,
  cliente_nome TEXT,
  destinatarios_extras TEXT,
  coordenador_id UUID REFERENCES usuarios(id),
  engenheiro_id UUID REFERENCES usuarios(id),
  tst_id UUID REFERENCES usuarios(id),
  docs_empresa TEXT[] DEFAULT '{}',
  docs_funcionario_base TEXT[] DEFAULT '{}',
  docs_maquina TEXT[] DEFAULT '{}',
  ativa BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT now()
);

-- ==========================================================
-- CATÁLOGO DE DOCUMENTOS
-- ==========================================================
CREATE TABLE catalogo_documentos (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  categoria TEXT NOT NULL CHECK (categoria IN ('empresa','funcionario','maquina')),
  validade_dias INT,
  descricao TEXT,
  checklist_ia TEXT
);

-- ==========================================================
-- CATÁLOGO DE FUNÇÕES
-- ==========================================================
CREATE TABLE catalogo_funcoes (
  id BIGSERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  docs_ids TEXT[] DEFAULT '{}'
);

-- ==========================================================
-- EMPRESAS
-- ==========================================================
CREATE TABLE empresas (
  id BIGSERIAL PRIMARY KEY,
  cnpj TEXT NOT NULL UNIQUE,
  razao TEXT NOT NULL,
  responsavel TEXT,
  email TEXT NOT NULL,
  telefone TEXT,
  criado_em TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE empresa_obras (
  empresa_id BIGINT REFERENCES empresas(id) ON DELETE CASCADE,
  obra_id BIGINT REFERENCES obras(id) ON DELETE CASCADE,
  PRIMARY KEY (empresa_id, obra_id)
);

-- ==========================================================
-- FUNCIONÁRIOS
-- ==========================================================
CREATE TABLE funcionarios (
  id BIGSERIAL PRIMARY KEY,
  empresa_id BIGINT NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  obra_id BIGINT REFERENCES obras(id),
  nome TEXT NOT NULL,
  cpf TEXT NOT NULL,
  funcao_id BIGINT REFERENCES catalogo_funcoes(id),
  ativo BOOLEAN DEFAULT true,
  criado_em TIMESTAMPTZ DEFAULT now()
);

-- ==========================================================
-- MÁQUINAS
-- ==========================================================
CREATE TABLE maquinas (
  id BIGSERIAL PRIMARY KEY,
  empresa_id BIGINT NOT NULL REFERENCES empresas(id) ON DELETE CASCADE,
  obra_id BIGINT REFERENCES obras(id),
  descricao TEXT NOT NULL,
  patrimonio TEXT,
  criado_em TIMESTAMPTZ DEFAULT now()
);

-- ==========================================================
-- DOCUMENTOS ENVIADOS
-- ==========================================================
CREATE TABLE documentos (
  id BIGSERIAL PRIMARY KEY,
  ref_tipo TEXT NOT NULL CHECK (ref_tipo IN ('empresa','funcionario','maquina')),
  ref_id BIGINT NOT NULL,
  obra_id BIGINT REFERENCES obras(id),
  doc_id TEXT NOT NULL REFERENCES catalogo_documentos(id),
  arquivo TEXT,
  arquivo_path TEXT,                          -- caminho no Storage Supabase
  emitido_em DATE,
  validade DATE,
  ia_status TEXT CHECK (ia_status IN ('pendente','aprovado','duvida','recusado')),
  ia_nota TEXT,
  sesmt_status TEXT DEFAULT 'pendente' CHECK (sesmt_status IN ('pendente','aprovado','recusado')),
  sesmt_motivo TEXT,
  sesmt_por UUID REFERENCES usuarios(id),
  enviado_em TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_doc_ref ON documentos(ref_tipo, ref_id, doc_id, obra_id);
CREATE INDEX idx_doc_status ON documentos(sesmt_status, validade);

-- ==========================================================
-- LOGS DE E-MAIL
-- ==========================================================
CREATE TABLE logs_email (
  id BIGSERIAL PRIMARY KEY,
  data TIMESTAMPTZ DEFAULT now(),
  para TEXT,
  cc TEXT,
  assunto TEXT,
  itens INT,
  enviado_por UUID REFERENCES usuarios(id),
  via TEXT
);

-- ==========================================================
-- CONFIGURAÇÕES GLOBAIS (1 linha)
-- ==========================================================
CREATE TABLE config (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  smtp_host TEXT, smtp_porta INT DEFAULT 587, smtp_user TEXT, smtp_pass TEXT, smtp_remetente TEXT,
  dias_aviso_vencimento INT DEFAULT 30,
  ia_habilitada BOOLEAN DEFAULT true,
  gemini_api_key TEXT,
  gemini_model TEXT DEFAULT 'gemini-2.0-flash',
  webhook_make TEXT,
  logo_data TEXT,
  nome_empresa TEXT DEFAULT 'BRANDÃO & MARMO',
  cor_primaria TEXT DEFAULT '#1a3d7c',
  cor_secundaria TEXT DEFAULT '#e8a23a'
);
INSERT INTO config (id) VALUES (1);

-- ==========================================================
-- ROW LEVEL SECURITY
-- ==========================================================
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE obras ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresas ENABLE ROW LEVEL SECURITY;
ALTER TABLE empresa_obras ENABLE ROW LEVEL SECURITY;
ALTER TABLE funcionarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE maquinas ENABLE ROW LEVEL SECURITY;
ALTER TABLE documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalogo_funcoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE logs_email ENABLE ROW LEVEL SECURITY;
ALTER TABLE config ENABLE ROW LEVEL SECURITY;

-- Helper: tipo do usuário logado
CREATE OR REPLACE FUNCTION user_tipo() RETURNS TEXT AS $$
  SELECT tipo FROM usuarios WHERE id = auth.uid();
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION user_obras() RETURNS BIGINT[] AS $$
  SELECT obra_ids FROM usuarios WHERE id = auth.uid();
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION user_empresa() RETURNS BIGINT AS $$
  SELECT empresa_id FROM usuarios WHERE id = auth.uid();
$$ LANGUAGE SQL STABLE;

-- Diretoria/SESMT: tudo
-- Outros perfis: leitura conforme obra/empresa vinculada
-- (Para simplicidade inicial, libera tudo para autenticados. Refine conforme necessário.)

CREATE POLICY p_all ON usuarios FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt') OR id = auth.uid());
CREATE POLICY p_all ON obras FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt'));
CREATE POLICY p_all ON empresas FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt'));
CREATE POLICY p_all ON empresa_obras FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt'));
CREATE POLICY p_all ON funcionarios FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt','empresa'));
CREATE POLICY p_all ON maquinas FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt','empresa'));
CREATE POLICY p_all ON documentos FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY p_all ON catalogo_documentos FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt'));
CREATE POLICY p_all ON catalogo_funcoes FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt'));
CREATE POLICY p_all ON logs_email FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY p_all ON config FOR ALL TO authenticated USING (true) WITH CHECK (user_tipo() IN ('diretoria','sesmt'));

-- ==========================================================
-- STORAGE: bucket "documentos"
-- ==========================================================
-- Crie manualmente no painel Storage do Supabase:
--   Bucket name: documentos
--   Public: false
-- E aplique policies (já dá pra colar isto):
INSERT INTO storage.buckets (id, name, public) VALUES ('documentos','documentos',false) ON CONFLICT DO NOTHING;

CREATE POLICY "Auth upload" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'documentos');
CREATE POLICY "Auth read" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'documentos');
CREATE POLICY "Auth delete" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'documentos');
