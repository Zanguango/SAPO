-- ============================================================================
-- S.A.P.O. - MIGRACION INCREMENTAL CONTROLADA DE sapo_db
-- DESTINO EXCLUSIVO: sapo_db_migracion_prueba
-- PostgreSQL 18.x
-- Referencia: database/schema/SAPO_SCHEMA.sql (blob SHA e3594567dbcb5eccb80bdca4da58e2ac4dabb5f6).
--
-- IMPORTANTE:
--   1. Este script NO se ejecuta en sapo_db.
--   2. Ejecutarlo solo despues de crear el segundo backup de la copia restaurada.
--   3. El script valida base de datos, inventario estructural y compatibilidad
--      de las filas antes de aplicar cambios.
--   4. Todo el DDL se ejecuta dentro de una transaccion. Ante un error, hacer
--      ROLLBACK desde pgAdmin; no intentar continuar parcialmente.
--   5. No recrea tablas, columnas, claves foraneas ni indices existentes.
-- ============================================================================

BEGIN;
SET LOCAL search_path = public, pg_catalog;

-- ============================================================================
-- 0. GUARDAS PREVIAS: DESTINO, VERSION, INVENTARIO Y DATOS
-- ============================================================================
DO $guard$
DECLARE
    v_count BIGINT;
BEGIN
    IF current_database() <> 'sapo_db_migracion_prueba' THEN
        RAISE EXCEPTION
            'MIGRACION ABORTADA: base actual = %, se exige sapo_db_migracion_prueba.',
            current_database();
    END IF;

    IF current_setting('server_version_num')::INTEGER < 180000
       OR current_setting('server_version_num')::INTEGER >= 190000 THEN
        RAISE EXCEPTION
            'MIGRACION ABORTADA: se requiere PostgreSQL 18.x; version actual = %.',
            current_setting('server_version');
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relkind IN ('r', 'p');
    IF v_count <> 24 THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: se esperaban 24 tablas public; encontradas %.', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns c
    WHERE c.table_schema = 'public'
      AND c.table_name IN (
          SELECT t.table_name
          FROM information_schema.tables t
          WHERE t.table_schema = 'public'
            AND t.table_type = 'BASE TABLE'
      );
    IF v_count <> 187 THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: se esperaban 187 columnas; encontradas %.', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM pg_constraint con
    JOIN pg_class t ON t.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND con.contype = 'f';
    IF v_count <> 31 THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: se esperaban 31 claves foraneas; encontradas %.', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM pg_indexes
    WHERE schemaname = 'public';
    IF v_count <> 71 THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: se esperaban 71 indices; encontrados %.', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM pg_constraint con
    JOIN pg_class t ON t.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND con.contype = 'c';
    IF v_count <> 40 THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: se esperaban 40 CHECK antes de migrar; encontradas %.', v_count;
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM pg_trigger tr
    JOIN pg_class t ON t.oid = tr.tgrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND NOT tr.tgisinternal;
    IF v_count <> 42 THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: se esperaban 42 triggers antes de migrar; encontrados %.', v_count;
    END IF;

    SELECT COUNT(DISTINCT p.proname) INTO v_count
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'
      AND left(p.proname, 3) = 'fn_';
    IF v_count <> 36 THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: se esperaban 36 funciones propias antes de migrar; encontradas %.', v_count;
    END IF;

    -- Las dos restricciones existentes que se van a reforzar deben estar presentes.
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_alerta_fechas'
          AND conrelid = 'public.alerta_tecnica'::regclass
          AND contype = 'c'
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_aviso_origen_deduplicacion'
          AND conrelid = 'public.aviso_seguimiento'::regclass
          AND contype = 'c'
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: no se encuentran las dos CHECK que deben reforzarse.';
    END IF;

    -- Las diez restricciones que se incorporan deben estar ausentes.
    IF EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname IN (
            'ck_aviso_fecha_gestion',
            'ck_auditoria_snapshots_objeto',
            'ck_ejecucion_codigo',
            'ck_ejecucion_identificador',
            'ck_ejecucion_error_fallida',
            'ck_alerta_texto',
            'ck_alerta_ocurrencia_cronologia',
            'ck_alerta_estado_fechas',
            'ck_alerta_observacion_final',
            'ck_actuacion_descripcion'
        )
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: alguna CHECK nueva ya existe; revisar estado antes de continuar.';
    END IF;

    -- Las funciones y triggers existentes que se sustituyen deben estar presentes.
    IF to_regprocedure('public.fn_proteger_archivado_persona()') IS NULL
       OR to_regprocedure('public.fn_proteger_incidente_archivado()') IS NULL
       OR to_regprocedure('public.fn_proteger_documento_asociado()') IS NULL
       OR to_regprocedure('public.fn_validar_aviso_seguimiento()') IS NULL
       OR to_regprocedure('public.fn_validar_alerta_tecnica()') IS NULL
       OR to_regprocedure('public.fn_validar_actuacion_alerta()') IS NULL
       OR to_regprocedure('public.fn_validar_alta_incidente()') IS NULL
       OR to_regprocedure('public.fn_validar_transicion_incidente()') IS NULL THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: falta alguna funcion existente que debe actualizarse.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'persona'
          AND tr.tgname = 'trg_proteger_archivado_persona'
          AND p.proname = 'fn_proteger_archivado_persona'
          AND NOT tr.tgisinternal
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'aviso_seguimiento'
          AND tr.tgname = 'trg_validar_aviso_seguimiento'
          AND p.proname = 'fn_validar_aviso_seguimiento'
          AND NOT tr.tgisinternal
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'incidente'
          AND tr.tgname = 'trg_proteger_incidente_archivado'
          AND p.proname = 'fn_proteger_incidente_archivado'
          AND NOT tr.tgisinternal
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'documento_asociado'
          AND tr.tgname = 'trg_proteger_documento_asociado'
          AND p.proname = 'fn_proteger_documento_asociado'
          AND NOT tr.tgisinternal
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'alerta_tecnica'
          AND tr.tgname = 'trg_validar_alerta_tecnica'
          AND p.proname = 'fn_validar_alerta_tecnica'
          AND NOT tr.tgisinternal
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'actuacion_alerta'
          AND tr.tgname = 'trg_validar_actuacion_alerta'
          AND p.proname = 'fn_validar_actuacion_alerta'
          AND NOT tr.tgisinternal
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'incidente'
          AND tr.tgname = 'trg_validar_alta_incidente'
          AND p.proname = 'fn_validar_alta_incidente'
          AND NOT tr.tgisinternal
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        JOIN pg_proc p ON p.oid = tr.tgfoid
        WHERE n.nspname = 'public' AND t.relname = 'incidente'
          AND tr.tgname = 'trg_validar_transicion_incidente'
          AND p.proname = 'fn_validar_transicion_incidente'
          AND NOT tr.tgisinternal
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: falta algun trigger que debe conservarse o ajustarse.';
    END IF;

    IF to_regprocedure('public.fn_bloquear_eliminacion_fisica()') IS NOT NULL THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: fn_bloquear_eliminacion_fisica ya existe; revisar estado.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_trigger
        WHERE tgname IN (
            'trg_bloquear_delete_organizacion',
            'trg_bloquear_delete_usuario',
            'trg_bloquear_delete_persona',
            'trg_bloquear_delete_incidente',
            'trg_bloquear_delete_antecedente',
            'trg_bloquear_delete_ubicacion'
        )
        AND NOT tgisinternal
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: alguno de los seis triggers nuevos ya existe; revisar estado.';
    END IF;

    -- Revalidacion en la copia de las doce reglas de compatibilidad de datos.
    IF EXISTS (
        SELECT 1 FROM AVISO_SEGUIMIENTO
        WHERE fecha_gestion IS NOT NULL
          AND fecha_gestion < fecha_creacion
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay AVISO_SEGUIMIENTO con fecha_gestion anterior a fecha_creacion.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM AUDITORIA
        WHERE (valores_anteriores IS NOT NULL AND jsonb_typeof(valores_anteriores) IS DISTINCT FROM 'object')
           OR (valores_nuevos IS NOT NULL AND jsonb_typeof(valores_nuevos) IS DISTINCT FROM 'object')
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay snapshots de AUDITORIA que no son objetos JSON.';
    END IF;

    IF EXISTS (SELECT 1 FROM EJECUCION_PROCESO WHERE BTRIM(codigo_proceso) = '') THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay codigo_proceso vacio.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM EJECUCION_PROCESO
        WHERE identificador_ejecucion IS NOT NULL
          AND BTRIM(identificador_ejecucion) = ''
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay identificadores de ejecucion vacios.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM EJECUCION_PROCESO
        WHERE estado = 'FALLIDA'
          AND (detalle_error IS NULL OR BTRIM(detalle_error) = '')
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay ejecuciones FALLIDA sin detalle_error.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ALERTA_TECNICA
        WHERE BTRIM(codigo) = ''
           OR BTRIM(origen) = ''
           OR BTRIM(descripcion) = ''
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay campos de texto vacios en ALERTA_TECNICA.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ALERTA_TECNICA
        WHERE ultima_ocurrencia < primera_ocurrencia
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay cronologias de alerta incompatibles.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ALERTA_TECNICA
        WHERE NOT (
            (estado IN ('NUEVA', 'EN_REVISION') AND fecha_resolucion IS NULL AND fecha_cierre IS NULL)
            OR (estado = 'RESUELTA' AND fecha_resolucion IS NOT NULL AND fecha_cierre IS NULL)
            OR (estado = 'CERRADA' AND fecha_resolucion IS NOT NULL AND fecha_cierre IS NOT NULL)
        )
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay combinaciones incompatibles de estado y fechas en ALERTA_TECNICA.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ALERTA_TECNICA
        WHERE observacion_final IS NOT NULL
          AND BTRIM(observacion_final) = ''
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay observaciones finales vacias.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ACTUACION_ALERTA
        WHERE BTRIM(descripcion) = ''
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay actuaciones con descripcion vacia.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ALERTA_TECNICA
        WHERE fecha_resolucion IS NOT NULL
          AND fecha_resolucion < primera_ocurrencia
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay fecha_resolucion anterior a primera_ocurrencia.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM ALERTA_TECNICA
        WHERE fecha_cierre IS NOT NULL
          AND fecha_resolucion IS NOT NULL
          AND fecha_cierre < fecha_resolucion
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay fecha_cierre anterior a fecha_resolucion.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM AVISO_SEGUIMIENTO
        WHERE origen = 'AUTOMATICO'
          AND clave_deduplicacion IS NOT NULL
          AND BTRIM(clave_deduplicacion) = ''
    ) THEN
        RAISE EXCEPTION 'MIGRACION ABORTADA: hay claves de deduplicacion automaticas vacias.';
    END IF;

    RAISE NOTICE 'Preflight correcto: base, inventario y compatibilidad de datos verificados.';
END;
$guard$;

-- ============================================================================
-- 1. RESTRICCIONES CHECK AUSENTES Y REFORZADAS
-- Las nuevas restricciones se validan contra las filas existentes.
-- ============================================================================

ALTER TABLE AVISO_SEGUIMIENTO
    ADD CONSTRAINT ck_aviso_fecha_gestion
    CHECK (fecha_gestion IS NULL OR fecha_gestion >= fecha_creacion) NOT VALID;
ALTER TABLE AVISO_SEGUIMIENTO VALIDATE CONSTRAINT ck_aviso_fecha_gestion;

ALTER TABLE AUDITORIA
    ADD CONSTRAINT ck_auditoria_snapshots_objeto
    CHECK (
        (valores_anteriores IS NULL OR jsonb_typeof(valores_anteriores) = 'object')
        AND
        (valores_nuevos IS NULL OR jsonb_typeof(valores_nuevos) = 'object')
    ) NOT VALID;
ALTER TABLE AUDITORIA VALIDATE CONSTRAINT ck_auditoria_snapshots_objeto;

ALTER TABLE EJECUCION_PROCESO
    ADD CONSTRAINT ck_ejecucion_codigo
    CHECK (BTRIM(codigo_proceso) <> '') NOT VALID;
ALTER TABLE EJECUCION_PROCESO VALIDATE CONSTRAINT ck_ejecucion_codigo;

ALTER TABLE EJECUCION_PROCESO
    ADD CONSTRAINT ck_ejecucion_identificador
    CHECK (identificador_ejecucion IS NULL OR BTRIM(identificador_ejecucion) <> '') NOT VALID;
ALTER TABLE EJECUCION_PROCESO VALIDATE CONSTRAINT ck_ejecucion_identificador;

ALTER TABLE EJECUCION_PROCESO
    ADD CONSTRAINT ck_ejecucion_error_fallida
    CHECK (
        estado <> 'FALLIDA'
        OR (detalle_error IS NOT NULL AND BTRIM(detalle_error) <> '')
    ) NOT VALID;
ALTER TABLE EJECUCION_PROCESO VALIDATE CONSTRAINT ck_ejecucion_error_fallida;

ALTER TABLE ALERTA_TECNICA
    ADD CONSTRAINT ck_alerta_texto
    CHECK (BTRIM(codigo) <> '' AND BTRIM(origen) <> '' AND BTRIM(descripcion) <> '') NOT VALID;
ALTER TABLE ALERTA_TECNICA VALIDATE CONSTRAINT ck_alerta_texto;

ALTER TABLE ALERTA_TECNICA
    ADD CONSTRAINT ck_alerta_ocurrencia_cronologia
    CHECK (ultima_ocurrencia >= primera_ocurrencia) NOT VALID;
ALTER TABLE ALERTA_TECNICA VALIDATE CONSTRAINT ck_alerta_ocurrencia_cronologia;

ALTER TABLE ALERTA_TECNICA
    ADD CONSTRAINT ck_alerta_estado_fechas
    CHECK (
        (estado IN ('NUEVA', 'EN_REVISION') AND fecha_resolucion IS NULL AND fecha_cierre IS NULL)
        OR (estado = 'RESUELTA' AND fecha_resolucion IS NOT NULL AND fecha_cierre IS NULL)
        OR (estado = 'CERRADA' AND fecha_resolucion IS NOT NULL AND fecha_cierre IS NOT NULL)
    ) NOT VALID;
ALTER TABLE ALERTA_TECNICA VALIDATE CONSTRAINT ck_alerta_estado_fechas;

ALTER TABLE ALERTA_TECNICA
    ADD CONSTRAINT ck_alerta_observacion_final
    CHECK (observacion_final IS NULL OR BTRIM(observacion_final) <> '') NOT VALID;
ALTER TABLE ALERTA_TECNICA VALIDATE CONSTRAINT ck_alerta_observacion_final;

ALTER TABLE ACTUACION_ALERTA
    ADD CONSTRAINT ck_actuacion_descripcion
    CHECK (BTRIM(descripcion) <> '') NOT VALID;
ALTER TABLE ACTUACION_ALERTA VALIDATE CONSTRAINT ck_actuacion_descripcion;

-- Reemplazo de la CHECK local menos restrictiva por la definicion canonica.
ALTER TABLE ALERTA_TECNICA DROP CONSTRAINT ck_alerta_fechas;
ALTER TABLE ALERTA_TECNICA
    ADD CONSTRAINT ck_alerta_fechas
    CHECK (
        (fecha_resolucion IS NULL OR fecha_resolucion >= primera_ocurrencia)
        AND
        (fecha_cierre IS NULL OR (fecha_resolucion IS NOT NULL AND fecha_cierre >= fecha_resolucion))
    ) NOT VALID;
ALTER TABLE ALERTA_TECNICA VALIDATE CONSTRAINT ck_alerta_fechas;

-- Reemplazo de la CHECK local menos restrictiva por la definicion canonica.
ALTER TABLE AVISO_SEGUIMIENTO DROP CONSTRAINT ck_aviso_origen_deduplicacion;
ALTER TABLE AVISO_SEGUIMIENTO
    ADD CONSTRAINT ck_aviso_origen_deduplicacion
    CHECK (
        (origen = 'AUTOMATICO' AND clave_deduplicacion IS NOT NULL AND BTRIM(clave_deduplicacion) <> '')
        OR
        (origen = 'MANUAL' AND clave_deduplicacion IS NULL)
    ) NOT VALID;
ALTER TABLE AVISO_SEGUIMIENTO VALIDATE CONSTRAINT ck_aviso_origen_deduplicacion;

-- ============================================================================
-- 2. FUNCIONES CANONICAS QUE SUSTITUYEN COMPORTAMIENTOS LOCALES DISTINTOS
-- Definiciones contrastadas con database/schema/SAPO_SCHEMA.sql.
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_bloquear_eliminacion_fisica()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION
        'La tabla % se gestiona mediante archivo logico; no se permite el borrado fisico.',
        TG_TABLE_NAME;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_proteger_archivado_persona()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo = FALSE AND NEW.activo = TRUE THEN
        IF NEW.dni IS DISTINCT FROM OLD.dni
           OR NEW.nombre IS DISTINCT FROM OLD.nombre
           OR NEW.apellidos IS DISTINCT FROM OLD.apellidos
           OR NEW.fecha_nacimiento IS DISTINCT FROM OLD.fecha_nacimiento
           OR NEW.telefono IS DISTINCT FROM OLD.telefono
           OR NEW.email IS DISTINCT FROM OLD.email
           OR NEW.domicilio IS DISTINCT FROM OLD.domicilio
           OR NEW.observaciones IS DISTINCT FROM OLD.observaciones
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
            RAISE EXCEPTION
                'La reactivacion de una persona no puede alterar sus datos.';
        END IF;
        RETURN NEW;
    END IF;

    IF OLD.activo = FALSE AND NEW IS DISTINCT FROM OLD THEN
        RAISE EXCEPTION 'Una persona archivada es inmutable.';
    END IF;

    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
        IF NEW.dni IS DISTINCT FROM OLD.dni
           OR NEW.nombre IS DISTINCT FROM OLD.nombre
           OR NEW.apellidos IS DISTINCT FROM OLD.apellidos
           OR NEW.fecha_nacimiento IS DISTINCT FROM OLD.fecha_nacimiento
           OR NEW.telefono IS DISTINCT FROM OLD.telefono
           OR NEW.email IS DISTINCT FROM OLD.email
           OR NEW.domicilio IS DISTINCT FROM OLD.domicilio
           OR NEW.observaciones IS DISTINCT FROM OLD.observaciones
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
            RAISE EXCEPTION
                'El archivo de una persona no puede combinarse con cambios en sus datos.';
        END IF;

        IF EXISTS (
            SELECT 1 FROM ANTECEDENTE a
            WHERE a.id_persona = OLD.id_persona
              AND a.activo = TRUE
              AND a.estado = 'PENDIENTE'
        ) THEN
            RAISE EXCEPTION 'No se puede archivar una persona con antecedentes pendientes.';
        END IF;

        IF EXISTS (
            SELECT 1
            FROM VINCULACION_PERSONA_INCIDENTE v
            JOIN INCIDENTE i ON i.id_incidente = v.id_incidente
            JOIN ESTADO_INCIDENTE e ON e.id_estado_incidente = i.id_estado_incidente
            WHERE v.id_persona = OLD.id_persona
              AND v.activo = TRUE
              AND i.activo = TRUE
              AND e.es_terminal = FALSE
        ) THEN
            RAISE EXCEPTION 'La persona mantiene vinculaciones con incidentes no resueltos.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_proteger_incidente_archivado()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.activo = TRUE AND NEW.activo = FALSE AND (
        NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion OR
        NEW.id_tipo_incidente IS DISTINCT FROM OLD.id_tipo_incidente OR
        NEW.id_estado_incidente IS DISTINCT FROM OLD.id_estado_incidente OR
        NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion OR
        NEW.titulo IS DISTINCT FROM OLD.titulo OR
        NEW.descripcion IS DISTINCT FROM OLD.descripcion OR
        NEW.fecha_incidente IS DISTINCT FROM OLD.fecha_incidente
    ) THEN
        RAISE EXCEPTION 'El archivo no puede combinarse con cambios operativos del incidente.';
    END IF;

    IF OLD.activo = FALSE AND NEW.activo = FALSE AND (
        NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion OR
        NEW.id_tipo_incidente IS DISTINCT FROM OLD.id_tipo_incidente OR
        NEW.id_estado_incidente IS DISTINCT FROM OLD.id_estado_incidente OR
        NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion OR
        NEW.titulo IS DISTINCT FROM OLD.titulo OR
        NEW.descripcion IS DISTINCT FROM OLD.descripcion OR
        NEW.fecha_incidente IS DISTINCT FROM OLD.fecha_incidente
    ) THEN
        RAISE EXCEPTION 'Un incidente archivado no admite modificaciones operativas.';
    END IF;

    IF OLD.activo = FALSE AND NEW.activo = TRUE AND (
        NEW.id_organizacion IS DISTINCT FROM OLD.id_organizacion OR
        NEW.id_tipo_incidente IS DISTINCT FROM OLD.id_tipo_incidente OR
        NEW.id_estado_incidente IS DISTINCT FROM OLD.id_estado_incidente OR
        NEW.id_ubicacion IS DISTINCT FROM OLD.id_ubicacion OR
        NEW.titulo IS DISTINCT FROM OLD.titulo OR
        NEW.descripcion IS DISTINCT FROM OLD.descripcion OR
        NEW.fecha_incidente IS DISTINCT FROM OLD.fecha_incidente
    ) THEN
        RAISE EXCEPTION 'La reactivacion no puede alterar los datos operativos del incidente.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_proteger_documento_asociado()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Los documentos asociados no se eliminan fisicamente.';
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
           OR NEW.id_persona IS DISTINCT FROM OLD.id_persona
           OR NEW.id_antecedente IS DISTINCT FROM OLD.id_antecedente
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
            RAISE EXCEPTION 'El destino y fecha de creacion del documento son inmutables.';
        END IF;

        IF OLD.activo = FALSE AND NEW IS DISTINCT FROM OLD THEN
            RAISE EXCEPTION 'Un documento archivado es inmutable.';
        END IF;

        IF OLD.activo = TRUE AND NEW.activo = FALSE AND (
            NEW.nombre IS DISTINCT FROM OLD.nombre
            OR NEW.tipo_documento IS DISTINCT FROM OLD.tipo_documento
            OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
            OR NEW.referencia_simulada IS DISTINCT FROM OLD.referencia_simulada
        ) THEN
            RAISE EXCEPTION 'El archivo de un documento no puede combinarse con cambios de contenido.';
        END IF;

        RETURN NEW;
    END IF;

    IF NEW.id_incidente IS NOT NULL THEN
        SELECT activo INTO v_activo FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente FOR UPDATE;
    ELSIF NEW.id_persona IS NOT NULL THEN
        SELECT activo INTO v_activo FROM PERSONA
        WHERE id_persona = NEW.id_persona FOR UPDATE;
    ELSE
        SELECT activo INTO v_activo FROM ANTECEDENTE
        WHERE id_antecedente = NEW.id_antecedente FOR UPDATE;
    END IF;

    IF NOT FOUND OR NOT v_activo THEN
        RAISE EXCEPTION 'El destino del documento debe existir y estar activo al crearlo.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validar_aviso_seguimiento()
RETURNS TRIGGER AS $$
DECLARE
    v_activo BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Los avisos de seguimiento se archivan; no se eliminan fisicamente.';
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF NEW.estado <> 'PENDIENTE'
           OR NEW.id_usuario_gestion IS NOT NULL
           OR NEW.fecha_gestion IS NOT NULL
           OR NEW.activo IS DISTINCT FROM TRUE THEN
            RAISE EXCEPTION 'Un aviso nuevo debe comenzar activo, PENDIENTE y sin responsable.';
        END IF;

        SELECT activo INTO v_activo
        FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente
        FOR UPDATE;

        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION 'El aviso requiere un incidente activo.';
        END IF;
        RETURN NEW;
    END IF;

    IF NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
       OR NEW.origen IS DISTINCT FROM OLD.origen
       OR NEW.clave_deduplicacion IS DISTINCT FROM OLD.clave_deduplicacion
       OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion THEN
        RAISE EXCEPTION 'La identidad del aviso es inmutable.';
    END IF;

    IF OLD.activo = FALSE THEN
        IF NEW.activo = FALSE THEN
            IF NEW IS DISTINCT FROM OLD THEN
                RAISE EXCEPTION 'Un aviso archivado es inmutable.';
            END IF;
            RETURN NEW;
        END IF;

        IF OLD.estado NOT IN ('GESTIONADO', 'CANCELADO')
           OR NEW.estado IS DISTINCT FROM OLD.estado
           OR NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion
           OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
           OR NEW.fecha_creacion IS DISTINCT FROM OLD.fecha_creacion
           OR NEW.id_incidente IS DISTINCT FROM OLD.id_incidente
           OR NEW.origen IS DISTINCT FROM OLD.origen
           OR NEW.clave_deduplicacion IS DISTINCT FROM OLD.clave_deduplicacion THEN
            RAISE EXCEPTION 'La reactivacion solo permite cambiar activo y conservar el aviso terminal.';
        END IF;

        SELECT activo INTO v_activo
        FROM INCIDENTE
        WHERE id_incidente = NEW.id_incidente
        FOR UPDATE;

        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION 'No se puede reactivar un aviso cuyo incidente esta archivado.';
        END IF;
        RETURN NEW;
    END IF;

    IF OLD.activo = TRUE AND NEW.activo = FALSE THEN
        IF OLD.estado NOT IN ('GESTIONADO', 'CANCELADO')
           OR NEW.estado IS DISTINCT FROM OLD.estado
           OR NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion
           OR NEW.descripcion IS DISTINCT FROM OLD.descripcion THEN
            RAISE EXCEPTION 'Solo se pueden archivar avisos terminales sin modificar sus datos.';
        END IF;
        RETURN NEW;
    END IF;

    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        IF NOT (
            (OLD.estado = 'PENDIENTE' AND NEW.estado IN ('EN_GESTION', 'CANCELADO'))
            OR
            (OLD.estado = 'EN_GESTION' AND NEW.estado IN ('GESTIONADO', 'CANCELADO'))
        ) THEN
            RAISE EXCEPTION 'Transicion de aviso no permitida.';
        END IF;

        IF NEW.estado = 'EN_GESTION' THEN
            SELECT activo INTO v_activo
            FROM USUARIO
            WHERE id_usuario = NEW.id_usuario_gestion
            FOR UPDATE;
            IF NOT FOUND OR NOT v_activo THEN
                RAISE EXCEPTION 'El responsable debe ser un usuario activo.';
            END IF;
            NEW.fecha_gestion := clock_timestamp();
        ELSIF OLD.estado = 'PENDIENTE' AND NEW.estado = 'CANCELADO' THEN
            IF NEW.id_usuario_gestion IS NOT NULL OR NEW.fecha_gestion IS NOT NULL THEN
                RAISE EXCEPTION 'La cancelacion desde PENDIENTE no lleva responsable.';
            END IF;
        ELSIF OLD.estado = 'EN_GESTION' THEN
            IF NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
               OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion THEN
                RAISE EXCEPTION 'El responsable y fecha de gestion son inmutables.';
            END IF;
        END IF;
    ELSE
        IF NEW.id_usuario_gestion IS DISTINCT FROM OLD.id_usuario_gestion
           OR NEW.fecha_gestion IS DISTINCT FROM OLD.fecha_gestion THEN
            RAISE EXCEPTION 'El responsable solo se establece al iniciar la gestion.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validar_alerta_tecnica()
RETURNS TRIGGER AS $$
DECLARE
    v_usuario_activo BOOLEAN;
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Las alertas tecnicas se conservan para garantizar la trazabilidad.';
    END IF;

    IF TG_OP = 'INSERT' THEN
        IF NEW.estado <> 'NUEVA'
           OR NEW.fecha_resolucion IS NOT NULL
           OR NEW.fecha_cierre IS NOT NULL THEN
            RAISE EXCEPTION 'Una alerta nueva debe comenzar NUEVA y sin fechas de resolucion/cierre.';
        END IF;

        IF NEW.id_usuario_responsable IS NOT NULL THEN
            SELECT activo INTO v_usuario_activo
            FROM USUARIO
            WHERE id_usuario = NEW.id_usuario_responsable
            FOR UPDATE;
            IF NOT FOUND OR NOT v_usuario_activo THEN
                RAISE EXCEPTION 'El responsable inicial de la alerta debe estar activo.';
            END IF;
        END IF;
        RETURN NEW;
    END IF;

    IF NEW.codigo IS DISTINCT FROM OLD.codigo
       OR NEW.origen IS DISTINCT FROM OLD.origen
       OR NEW.recurso IS DISTINCT FROM OLD.recurso
       OR NEW.id_alerta_anterior IS DISTINCT FROM OLD.id_alerta_anterior
       OR NEW.primera_ocurrencia IS DISTINCT FROM OLD.primera_ocurrencia THEN
        RAISE EXCEPTION 'La identidad de una alerta es inmutable.';
    END IF;

    IF OLD.estado = 'CERRADA' AND NEW IS DISTINCT FROM OLD THEN
        RAISE EXCEPTION 'Una alerta cerrada es inmutable.';
    END IF;

    IF NEW.observacion_final IS DISTINCT FROM OLD.observacion_final
       AND NOT (OLD.estado = 'RESUELTA' AND NEW.estado = 'CERRADA') THEN
        RAISE EXCEPTION 'La observacion final solo se introduce al cerrar la alerta.';
    END IF;

    IF OLD.estado = 'RESUELTA' AND (
        NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable
        OR NEW.id_alerta_anterior IS DISTINCT FROM OLD.id_alerta_anterior
        OR NEW.codigo IS DISTINCT FROM OLD.codigo
        OR NEW.origen IS DISTINCT FROM OLD.origen
        OR NEW.recurso IS DISTINCT FROM OLD.recurso
        OR NEW.severidad IS DISTINCT FROM OLD.severidad
        OR NEW.descripcion IS DISTINCT FROM OLD.descripcion
        OR NEW.numero_ocurrencias IS DISTINCT FROM OLD.numero_ocurrencias
        OR NEW.primera_ocurrencia IS DISTINCT FROM OLD.primera_ocurrencia
        OR NEW.ultima_ocurrencia IS DISTINCT FROM OLD.ultima_ocurrencia
        OR NEW.fecha_resolucion IS DISTINCT FROM OLD.fecha_resolucion
    ) THEN
        RAISE EXCEPTION 'Una alerta resuelta solo permite registrar su cierre y observacion final.';
    END IF;

    IF NEW.numero_ocurrencias < OLD.numero_ocurrencias
       OR NEW.ultima_ocurrencia < OLD.ultima_ocurrencia THEN
        RAISE EXCEPTION 'El contador y la ultima ocurrencia no pueden retroceder.';
    END IF;

    IF OLD.id_usuario_responsable IS NOT NULL
       AND NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable THEN
        RAISE EXCEPTION 'El responsable de una alerta no se puede sustituir ni retirar.';
    END IF;

    IF NEW.id_usuario_responsable IS NOT NULL
       AND NEW.id_usuario_responsable IS DISTINCT FROM OLD.id_usuario_responsable THEN
        SELECT activo INTO v_usuario_activo
        FROM USUARIO
        WHERE id_usuario = NEW.id_usuario_responsable
        FOR UPDATE;
        IF NOT FOUND OR NOT v_usuario_activo THEN
            RAISE EXCEPTION 'El responsable de la alerta debe estar activo.';
        END IF;
    END IF;

    IF OLD.fecha_resolucion IS NOT NULL
       AND NEW.fecha_resolucion IS DISTINCT FROM OLD.fecha_resolucion THEN
        RAISE EXCEPTION 'La fecha de resolucion es inmutable una vez establecida.';
    END IF;

    IF OLD.fecha_resolucion IS NULL
       AND NEW.fecha_resolucion IS NOT NULL
       AND NOT (OLD.estado IS DISTINCT FROM NEW.estado AND NEW.estado = 'RESUELTA') THEN
        RAISE EXCEPTION 'La fecha de resolucion solo se establece al resolver la alerta.';
    END IF;

    IF NEW.fecha_cierre IS DISTINCT FROM OLD.fecha_cierre
       AND NOT (OLD.estado IS DISTINCT FROM NEW.estado AND NEW.estado = 'CERRADA') THEN
        RAISE EXCEPTION 'La fecha de cierre solo la establece el trigger.';
    END IF;

    IF NEW.estado IS DISTINCT FROM OLD.estado THEN
        IF NOT (
            (OLD.estado = 'NUEVA' AND NEW.estado IN ('EN_REVISION', 'RESUELTA'))
            OR (OLD.estado = 'EN_REVISION' AND NEW.estado = 'RESUELTA')
            OR (OLD.estado = 'RESUELTA' AND NEW.estado = 'CERRADA')
        ) THEN
            RAISE EXCEPTION 'Transicion de alerta no permitida.';
        END IF;

        IF NEW.estado = 'EN_REVISION' AND NEW.id_usuario_responsable IS NULL THEN
            RAISE EXCEPTION 'Una alerta en revision requiere responsable.';
        END IF;

        IF NEW.estado = 'RESUELTA' THEN
            IF NOT EXISTS (
                SELECT 1 FROM ACTUACION_ALERTA
                WHERE id_alerta = OLD.id_alerta
                  AND tipo_actuacion = 'ACCION_CORRECTIVA'
            ) OR NOT EXISTS (
                SELECT 1 FROM ACTUACION_ALERTA
                WHERE id_alerta = OLD.id_alerta
                  AND tipo_actuacion = 'VERIFICACION'
            ) THEN
                RAISE EXCEPTION 'Para resolver se requiere accion correctiva y verificacion registradas.';
            END IF;
            NEW.fecha_resolucion := clock_timestamp();
        END IF;

        IF NEW.estado = 'CERRADA' THEN
            IF OLD.fecha_resolucion IS NULL
               OR NEW.observacion_final IS NULL
               OR BTRIM(NEW.observacion_final) = '' THEN
                RAISE EXCEPTION 'El cierre requiere resolucion previa y observacion final.';
            END IF;
            NEW.fecha_cierre := clock_timestamp();
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validar_actuacion_alerta()
RETURNS TRIGGER AS $$
DECLARE
    v_estado VARCHAR(20);
    v_activo BOOLEAN;
    v_primera_ocurrencia TIMESTAMPTZ;
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        RAISE EXCEPTION 'Las actuaciones de alerta son append-only.';
    END IF;

    SELECT estado, primera_ocurrencia
    INTO v_estado, v_primera_ocurrencia
    FROM ALERTA_TECNICA
    WHERE id_alerta = NEW.id_alerta
    FOR UPDATE;

    IF NOT FOUND OR v_estado IN ('RESUELTA', 'CERRADA') THEN
        RAISE EXCEPTION 'No se pueden anadir actuaciones a una alerta resuelta o cerrada.';
    END IF;

    IF NEW.fecha_actuacion < v_primera_ocurrencia THEN
        RAISE EXCEPTION 'La actuacion no puede ser anterior a la primera ocurrencia de la alerta.';
    END IF;

    IF NEW.id_usuario IS NOT NULL THEN
        SELECT activo INTO v_activo
        FROM USUARIO
        WHERE id_usuario = NEW.id_usuario
        FOR UPDATE;
        IF NOT FOUND OR NOT v_activo THEN
            RAISE EXCEPTION 'El usuario que registra la actuacion debe estar activo.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validar_alta_incidente()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_registrado BIGINT;
    v_organizacion_activa BOOLEAN;
    v_tipo_activo BOOLEAN;
    v_ubicacion_activa BOOLEAN;
BEGIN
    SELECT id_estado_incidente
    INTO v_estado_registrado
    FROM ESTADO_INCIDENTE
    WHERE codigo = 'REGISTRADO'
      AND activo = TRUE;

    IF v_estado_registrado IS NULL THEN
        RAISE EXCEPTION 'No existe un estado REGISTRADO activo.';
    END IF;

    NEW.id_estado_incidente := v_estado_registrado;

    SELECT activo INTO v_organizacion_activa
    FROM ORGANIZACION
    WHERE id_organizacion = NEW.id_organizacion
    FOR SHARE;
    IF COALESCE(v_organizacion_activa, FALSE) = FALSE THEN
        RAISE EXCEPTION 'La organizacion del incidente debe estar activa.';
    END IF;

    SELECT activo INTO v_tipo_activo
    FROM TIPO_INCIDENTE
    WHERE id_tipo_incidente = NEW.id_tipo_incidente
    FOR SHARE;
    IF COALESCE(v_tipo_activo, FALSE) = FALSE THEN
        RAISE EXCEPTION 'El tipo de incidente debe estar activo.';
    END IF;

    IF NEW.id_ubicacion IS NOT NULL THEN
        SELECT activo INTO v_ubicacion_activa
        FROM UBICACION
        WHERE id_ubicacion = NEW.id_ubicacion
        FOR SHARE;
        IF COALESCE(v_ubicacion_activa, FALSE) = FALSE THEN
            RAISE EXCEPTION 'La ubicacion debe estar activa.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_validar_transicion_incidente()
RETURNS TRIGGER AS $$
DECLARE
    v_terminal_origen BOOLEAN;
    v_activo_destino BOOLEAN;
    v_transicion_activa BOOLEAN;
BEGIN
    IF NEW.id_estado_incidente IS NOT DISTINCT FROM OLD.id_estado_incidente THEN
        RETURN NEW;
    END IF;

    IF OLD.activo = FALSE OR NEW.activo = FALSE THEN
        RAISE EXCEPTION 'No se puede cambiar el estado de un incidente archivado.';
    END IF;

    SELECT activo INTO v_transicion_activa
    FROM TRANSICION_ESTADO_INCIDENTE
    WHERE id_estado_origen = OLD.id_estado_incidente
      AND id_estado_destino = NEW.id_estado_incidente
    FOR UPDATE;
    IF NOT FOUND OR NOT v_transicion_activa THEN
        RAISE EXCEPTION 'La transicion solicitada no esta autorizada en el catalogo.';
    END IF;

    SELECT es_terminal INTO v_terminal_origen
    FROM ESTADO_INCIDENTE
    WHERE id_estado_incidente = OLD.id_estado_incidente
    FOR UPDATE;
    IF NOT FOUND OR v_terminal_origen THEN
        RAISE EXCEPTION 'Un incidente en estado terminal no puede reabrirse.';
    END IF;

    SELECT activo INTO v_activo_destino
    FROM ESTADO_INCIDENTE
    WHERE id_estado_incidente = NEW.id_estado_incidente
    FOR UPDATE;
    IF NOT FOUND OR NOT v_activo_destino THEN
        RAISE EXCEPTION 'El estado de destino debe estar activo.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 3. TRIGGERS: SEIS NUEVOS Y DOS EVENTOS AJUSTADOS
-- ============================================================================

DROP TRIGGER trg_proteger_archivado_persona ON PERSONA;
CREATE TRIGGER trg_proteger_archivado_persona
BEFORE UPDATE ON PERSONA
FOR EACH ROW
EXECUTE FUNCTION fn_proteger_archivado_persona();

DROP TRIGGER trg_validar_aviso_seguimiento ON AVISO_SEGUIMIENTO;
CREATE TRIGGER trg_validar_aviso_seguimiento
BEFORE INSERT OR UPDATE OR DELETE ON AVISO_SEGUIMIENTO
FOR EACH ROW
EXECUTE FUNCTION fn_validar_aviso_seguimiento();

CREATE TRIGGER trg_bloquear_delete_organizacion
BEFORE DELETE ON ORGANIZACION
FOR EACH ROW EXECUTE FUNCTION fn_bloquear_eliminacion_fisica();

CREATE TRIGGER trg_bloquear_delete_usuario
BEFORE DELETE ON USUARIO
FOR EACH ROW EXECUTE FUNCTION fn_bloquear_eliminacion_fisica();

CREATE TRIGGER trg_bloquear_delete_persona
BEFORE DELETE ON PERSONA
FOR EACH ROW EXECUTE FUNCTION fn_bloquear_eliminacion_fisica();

CREATE TRIGGER trg_bloquear_delete_incidente
BEFORE DELETE ON INCIDENTE
FOR EACH ROW EXECUTE FUNCTION fn_bloquear_eliminacion_fisica();

CREATE TRIGGER trg_bloquear_delete_antecedente
BEFORE DELETE ON ANTECEDENTE
FOR EACH ROW EXECUTE FUNCTION fn_bloquear_eliminacion_fisica();

CREATE TRIGGER trg_bloquear_delete_ubicacion
BEFORE DELETE ON UBICACION
FOR EACH ROW EXECUTE FUNCTION fn_bloquear_eliminacion_fisica();

-- ============================================================================
-- 4. COMPROBACION POSTERIOR: INVENTARIO CANONICO ESPERADO
-- ============================================================================
DO $postflight$
DECLARE
    v_checks BIGINT;
    v_triggers BIGINT;
    v_functions BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_checks
    FROM pg_constraint con
    JOIN pg_class t ON t.oid = con.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND con.contype = 'c';

    SELECT COUNT(*) INTO v_triggers
    FROM pg_trigger tr
    JOIN pg_class t ON t.oid = tr.tgrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND NOT tr.tgisinternal;

    SELECT COUNT(DISTINCT p.proname) INTO v_functions
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'
      AND left(p.proname, 3) = 'fn_';

    IF v_checks <> 50 OR v_triggers <> 48 OR v_functions <> 37 THEN
        RAISE EXCEPTION
            'POSTFLIGHT FALLIDO: CHECK %, triggers %, funciones propias %; se esperaban 50, 48 y 37.',
            v_checks, v_triggers, v_functions;
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname IN (
            'ck_aviso_fecha_gestion',
            'ck_auditoria_snapshots_objeto',
            'ck_ejecucion_codigo',
            'ck_ejecucion_identificador',
            'ck_ejecucion_error_fallida',
            'ck_alerta_texto',
            'ck_alerta_ocurrencia_cronologia',
            'ck_alerta_estado_fechas',
            'ck_alerta_observacion_final',
            'ck_actuacion_descripcion'
        )
          AND NOT convalidated
    ) THEN
        RAISE EXCEPTION 'POSTFLIGHT FALLIDO: alguna restriccion CHECK no ha quedado validada.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bloquear_delete_organizacion' AND NOT tgisinternal)
       OR NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bloquear_delete_usuario' AND NOT tgisinternal)
       OR NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bloquear_delete_persona' AND NOT tgisinternal)
       OR NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bloquear_delete_incidente' AND NOT tgisinternal)
       OR NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bloquear_delete_antecedente' AND NOT tgisinternal)
       OR NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_bloquear_delete_ubicacion' AND NOT tgisinternal) THEN
        RAISE EXCEPTION 'POSTFLIGHT FALLIDO: falta alguno de los seis triggers de borrado fisico.';
    END IF;

    IF EXISTS (
        SELECT 1 FROM pg_trigger tr
        WHERE tr.tgname = 'trg_proteger_archivado_persona'
          AND NOT tr.tgisinternal
          AND pg_get_triggerdef(tr.oid, TRUE) ILIKE '%UPDATE OF%'
    ) THEN
        RAISE EXCEPTION 'POSTFLIGHT FALLIDO: trg_proteger_archivado_persona sigue limitado a UPDATE OF.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger tr
        WHERE tr.tgname = 'trg_validar_aviso_seguimiento'
          AND NOT tr.tgisinternal
          AND (tr.tgtype & 28) = 28
    ) THEN
        RAISE EXCEPTION 'POSTFLIGHT FALLIDO: trg_validar_aviso_seguimiento no cubre INSERT, UPDATE y DELETE.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_alerta_fechas'
          AND conrelid = 'public.alerta_tecnica'::regclass
          AND convalidated
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_aviso_origen_deduplicacion'
          AND conrelid = 'public.aviso_seguimiento'::regclass
          AND convalidated
    ) THEN
        RAISE EXCEPTION 'POSTFLIGHT FALLIDO: las dos CHECK reforzadas no han quedado validadas.';
    END IF;

    RAISE NOTICE 'POSTFLIGHT CORRECTO: 50 CHECK validadas, 48 triggers y 37 funciones propias.';
END;
$postflight$;

COMMIT;

-- Al finalizar, ejecutar por separado y SOLO en sapo_db_migracion_prueba:
--   1. database/diagnostics/AUDITAR_ESQUEMA_LOCAL_SOLO_LECTURA.sql
--   2. database/diagnostics/VERIFICAR_COPIA_RESTAURADA_SAPO_SOLO_LECTURA.sql
--   3. database/tests/TEST_REGLAS_INTEGRIDAD.sql
-- No ejecutar estos pasos en sapo_db.
