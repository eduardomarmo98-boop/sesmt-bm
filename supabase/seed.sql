-- ==========================================================
-- SEED: Catálogo de documentos e funções (B&M rev 04)
-- Execute APÓS schema.sql
-- ==========================================================

-- ========== DOCUMENTOS DA EMPRESA ==========
INSERT INTO catalogo_documentos (id,nome,categoria,validade_dias,descricao,checklist_ia) VALUES
('cnpj','Cartão CNPJ','empresa',90,'Cartão CNPJ atualizado','Confirme que é um Cartão CNPJ da Receita Federal, com CNPJ, razão social, situação cadastral ATIVA e data de emissão de no máximo 90 dias.'),
('contrato_social','Contrato Social','empresa',NULL,'Última alteração contratual','Confirme que é um Contrato Social (ou última alteração), com CNPJ, razão social, sócios identificados e registro na Junta Comercial.'),
('contrato_terceiro','Contrato de Terceirização','empresa',NULL,'Contrato que vincule terceirizadas','Confirme que é um contrato vinculando duas empresas, com objeto, prazo e assinaturas.'),

-- ========== DOCUMENTOS DO FUNCIONÁRIO - RH ==========
('cpf','CPF','funcionario',NULL,'Cópia simples','Confirme que é cópia de CPF legível, com nome e número do CPF visíveis.'),
('rg','RG ou CNH válida','funcionario',NULL,'Cópia simples','Confirme que é cópia de RG ou CNH. Se CNH, verificar se está dentro da validade.'),
('foto','Foto 3x4','funcionario',NULL,'','Confirme que contém foto 3x4 do colaborador, legível, recente.'),
('ficha_registro','Ficha de Registro do Funcionário','funcionario',NULL,'','Confirme Ficha de Registro de Empregado com nome, CPF, data admissão, função, salário e empregador.'),
('ctps','CTPS','funcionario',NULL,'Frente, verso e página de registro','Confirme cópia da CTPS com frente, verso e página de registro empregatício carimbada/registrada.'),

-- ========== DOCUMENTOS DO FUNCIONÁRIO - SST ==========
('aso','ASO - Atestado de Saúde Ocupacional','funcionario',365,'Da clínica do PCMSO ou credenciada','Confirme ASO com: nome do colaborador, função, tipo de exame, riscos avaliados, data, APTO ou INAPTO, nome do médico com CRM e assinatura. Validade máx 1 ano.'),
('nr01_os','NR-01 Ordem de Serviço (OS)','funcionario',730,'Ordem de serviço assinada','Confirme Ordem de Serviço (NR-01) listando atividades, riscos da função, EPIs obrigatórios. Assinada pelo colaborador.'),
('nr06_epi','NR-06 Ficha de Entrega de EPI','funcionario',180,'Assinada e atualizada','Confirme Ficha de Entrega de EPI com: nome, lista de EPIs, número CA de cada EPI, datas, assinaturas do colaborador. Atualizada nos últimos 180 dias.'),
('nr18','NR-18 Treinamento Admissional','funcionario',730,'','Confirme Certificado NR-18 (Indústria da Construção), carga horária mín 8h, nome do colaborador, data, conteúdo programático e instrutor.'),
('pcmso','PCMSO','funcionario',365,'Assinado pelo Médico Coordenador','Confirme PCMSO elaborado e assinado pelo Médico Coordenador (nome e CRM). Lista funções, riscos e exames. Validade 1 ano.'),
('apr','APR - Análise Preliminar do Risco','funcionario',90,'','Confirme APR descrevendo atividade, riscos, controles, EPIs e assinaturas. Atualizada.'),
('pgr','PGR - Programa de Gerenciamento de Riscos','funcionario',365,'','Confirme PGR (NR-01) com inventário de riscos, plano de ação, responsável técnico com qualificação. Validade 1 ano.'),
('ppr','PPR - Programa de Proteção Respiratória','funcionario',365,'Quando há proteção respiratória','Confirme PPR com avaliação de exposição, seleção de respiradores, treinamento e responsável técnico.'),
('vacinacao','Carteira de Vacinação','funcionario',365,'Doses atualizadas + COVID','Confirme carteira de vacinação (física ou ConecteSUS) com nome e doses recentes. Verifique COVID-19, Tétano, Hepatite B, Febre Amarela.'),

-- ========== NRs POR FUNÇÃO ==========
('nr10','NR-10 Segurança em Eletricidade','funcionario',730,'','Certificado NR-10 (Básico 40h ou SEP 40h+40h). Conferir nome, carga horária, data, conteúdo, instrutor com qualificação em eletricidade. Reciclagem bienal.'),
('nr11','NR-11 Operador de Veículos Industriais','funcionario',365,'','Certificado NR-11. Tipo de equipamento, carga horária mín 16h, nome do colaborador, prática supervisionada. Reciclagem anual.'),
('nr12','NR-12 Máquinas e Equipamentos','funcionario',730,'','Certificado NR-12 com carga horária compatível (mín 8h), conteúdo segurança em máquinas, nome do operador.'),
('nr33','NR-33 Trabalho em Espaço Confinado','funcionario',365,'','Certificado NR-33. Função especificada (Trabalhador Autorizado, Vigia ou Supervisor). Carga horária mín 16h (trab/vigia) ou 40h (supervisor). Reciclagem anual.'),
('nr34','NR-34 Soldador / Soldas','funcionario',730,'','Certificado NR-34 ou Soldador qualificado. Carga horária mín 8h. Riscos de soldagem, EPIs, espaço confinado se aplicável.'),
('nr35','NR-35 Trabalho em Altura','funcionario',730,'','Certificado NR-35 (acima de 2m). Nome do colaborador, carga horária mín 8h (inicial) ou 4h (reciclagem bienal), instrutor capacitado, resgate em altura.'),

-- ========== DOCUMENTOS DE MÁQUINA ==========
('laudo_art','Laudo de Conformidade com nº ART','maquina',365,'','Laudo de Conformidade NR-12 emitido por engenheiro habilitado, com número de ART do CREA, descrição da máquina e conclusão.'),
('art','ART','maquina',365,'','Anotação de Responsabilidade Técnica do CREA, número de ART, engenheiro responsável, CREA, objeto, data, valor pago.'),
('plano_manut','Plano de Manutenção','maquina',365,'','Plano de Manutenção preventiva, periodicidade, itens a inspecionar, responsável técnico.'),
('manual_pt','Manual em Português','maquina',NULL,'','Manual de Operação/Instruções em PORTUGUÊS com instruções de segurança, operação e manutenção.'),
('checklist','Check-list','maquina',30,'Inspeção periódica','Check-list de inspeção do equipamento, data recente, itens verificados, status, assinatura.'),
('historico_manut','Histórico de Manutenção','maquina',365,'Último ano','Histórico de Manutenções dos últimos 12 meses, datas, serviços e responsáveis.');

-- ========== FUNÇÕES PADRÃO ==========
INSERT INTO catalogo_funcoes (nome, docs_ids) VALUES
('Ajudante Geral', ARRAY['cpf','rg','foto','ficha_registro','ctps','aso','nr01_os','nr06_epi','nr18','vacinacao']),
('Pedreiro', ARRAY['cpf','rg','foto','ficha_registro','ctps','aso','nr01_os','nr06_epi','nr18','vacinacao']),
('Soldador', ARRAY['cpf','rg','foto','ficha_registro','ctps','aso','nr01_os','nr06_epi','nr18','vacinacao','nr34','nr35','ppr']),
('Eletricista', ARRAY['cpf','rg','foto','ficha_registro','ctps','aso','nr01_os','nr06_epi','nr18','vacinacao','nr10','nr35']),
('Operador de Empilhadeira', ARRAY['cpf','rg','foto','ficha_registro','ctps','aso','nr01_os','nr06_epi','nr18','vacinacao','nr11','nr12']),
('Trabalhador em Altura', ARRAY['cpf','rg','foto','ficha_registro','ctps','aso','nr01_os','nr06_epi','nr18','vacinacao','nr35']);
