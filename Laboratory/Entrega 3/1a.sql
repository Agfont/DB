-- 1.a)
-- Religioso
CREATE OR REPLACE FUNCTION exclusividade_confRelig() RETURN TRIGGER AS $relig$
BEGIN
    IF EXISTS(SELECT conflito_id FROM ConfEcon 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo econômico.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfRegiao 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo territorial.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfEtnia 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo étnico.', NEW.conflito_id;
    END IF;
    RETURN NEW;
END;
$relig$
LANGUAGE plpgsql;

CREATE TRIGGER conflito_religioso BEFORE INSERT OR UPDATE on ConfRelig
FOR EACH ROW EXECUTE PROCEDURE exclusividade_confRelig();

-- Econômico
CREATE OR REPLACE FUNCTION exclusividade_confEcon() RETURN TRIGGER AS $econ$
BEGIN
    IF EXISTS(SELECT conflito_id FROM ConfRelig 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo religioso.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfRegiao 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo territorial.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfEtnia 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo étnico.', NEW.conflito_id;
    END IF;
    RETURN NEW;
END;
$econ$
LANGUAGE plpgsql;

CREATE TRIGGER conflito_economico BEFORE INSERT OR UPDATE on ConfEcon
FOR EACH ROW EXECUTE PROCEDURE exclusividade_confEcon();

-- Territorial
CREATE OR REPLACE FUNCTION exclusividade_confTerritorial() RETURN TRIGGER AS $territorial$
BEGIN
    IF EXISTS(SELECT conflito_id FROM ConfRelig 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo religioso.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfEcon 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo econômico.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfEtnia 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo étnico.', NEW.conflito_id;
    END IF;
    RETURN NEW;
END;
$territorial$
LANGUAGE plpgsql;

CREATE TRIGGER conflito_economico BEFORE INSERT OR UPDATE on ConfRegiao
FOR EACH ROW EXECUTE PROCEDURE exclusividade_confTerritorial();

-- Étnico
CREATE OR REPLACE FUNCTION exclusividade_confEtnico() RETURN TRIGGER AS $etnico$
BEGIN
    IF EXISTS(SELECT conflito_id FROM ConfRelig 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo religioso.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfEcon 
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo econômico.', NEW.conflito_id;
    ELSIF EXISTS(SELECT conflito_id FROM ConfTerritorial  
              WHERE conflito_id = NEW.conflito_id) THEN
         RAISE EXCEPTION 'Erro: O conflito % já é do tipo territorial.', NEW.conflito_id;
    END IF;
    RETURN NEW;
END;
$etnico$
LANGUAGE plpgsql;

CREATE TRIGGER conflito_economico BEFORE INSERT OR UPDATE on ConfRegiao
FOR EACH ROW EXECUTE PROCEDURE exclusividade_confEtnico();