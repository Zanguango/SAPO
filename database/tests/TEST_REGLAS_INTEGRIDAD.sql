-- ============================================================
-- S.A.P.O. - Pruebas de integridad del esquema
-- Requisito: ejecutar DESPUÉS del SQL candidato en una BD aislada.
-- Compatible con PostgreSQL 18.7.
--
-- Este archivo:
--   * comprueba el inventario básico del esquema;
--   * ejecuta casos positivos y negativos de alertas, avisos,
--     auditoría y ejecuciones de proceso;
--   * revierte los datos de prueba al finalizar.
--
-- No ejecutar en la base local de trabajo ni en producción.
-- ============================================================

BEGIN;

DO $tests$
DECLARE
    v_org BIGINT;
    v_tipo BIGINT;
    v_incidente BIGINT;
    v_alerta BIGINT;
    v_aviso BIGINT;
    v_ejecucion BIGINT;
    v_usuario BIGINT;
    v_registrado BIGINT;
    v_rejected BOOLEAN;
    v_fecha_fin TIMESTAMPTZ;
    v_prefix TEXT := 'TEST_' || txid_current()::TEXT;
BEGIN
    -- --------------------------------------------------------
    -- 1. Comprobaciones estructurales mínimas
    -- --------------------------------------------------------
    IF (SELECT COUNT(*) FROM pg_tables WHERE schemaname = current_schema()) <> 24 THEN
        RAISE EXCEPTION 'TEST FALLIDO: el esquema no contiene 24 tablas.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM pg_constraint c
        JOIN pg_class t ON t.oid = c.conrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = current_schema()
          AND c.contype = 'f'
    ) <> 31 THEN
        RAISE EXCEPTION 'TEST FALLIDO: el esquema no contiene 31 claves foráneas.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM pg_trigger tr
        JOIN pg_class t ON t.oid = tr.tgrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = current_schema()
          AND NOT tr.tgisinternal
    ) <> 42 THEN
        RAISE EXCEPTION 'TEST FALLIDO: el esquema no contiene 42 triggers.';
    END IF;

    IF (
        SELECT COUNT(DISTINCT p.proname)
        FROM pg_proc p
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE n.nspname = current_schema()
          AND p.proname LIKE 'fn\_%' ESCAPE '\'
    ) <> 36 THEN
        RAISE EXCEPTION 'TEST FALLIDO: no se encuentran los 36 nombres de funciones propias.';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_alerta_estado_fechas'
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_aviso_fecha_gestion'
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_ejecucion_error_fallida'
    ) OR NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'ck_auditoria_snapshots_objeto'
    ) THEN
        RAISE EXCEPTION 'TEST FALLIDO: faltan restricciones nuevas de integridad.';
    END IF;

    -- --------------------------------------------------------
    -- 2. Datos de prueba ficticios para el circuito de avisos
    -- --------------------------------------------------------
    INSERT INTO ORGANIZACION (nombre, descripcion)
    VALUES (v_prefix || '_ORG', 'Organización ficticia para pruebas')
    RETURNING id_organizacion INTO v_org;

    INSERT INTO TIPO_INCIDENTE (nombre, descripcion)
    VALUES (v_prefix || '_TIPO', 'Tipo ficticio para pruebas')
    RETURNING id_tipo_incidente INTO v_tipo;

    SELECT id_estado_incidente
    INTO v_registrado
    FROM ESTADO_INCIDENTE
    WHERE codigo = 'REGISTRADO'
      AND activo = TRUE;

    IF v_registrado IS NULL THEN
        RAISE EXCEPTION 'TEST FALLIDO: no existe el estado REGISTRADO activo.';
    END IF;

    INSERT INTO INCIDENTE (
        id_organizacion,
        id_tipo_incidente,
        id_estado_incidente,
        titulo,
        descripcion,
        fecha_incidente
    )
    VALUES (
        v_org,
        v_tipo,
        v_registrado,
        'Incidente ficticio de prueba',
        'Registro temporal generado por la batería de pruebas',
        clock_timestamp()
    )
    RETURNING id_incidente INTO v_incidente;

    -- --------------------------------------------------------
    -- 3. Alertas: alta, evidencia, resolución y cierre
    -- --------------------------------------------------------
    INSERT INTO ALERTA_TECNICA (
        codigo,
        origen,
        severidad,
        descripcion
    )
    VALUES (
        v_prefix || '_ALERTA',
        'TEST',
        'WARNING',
        'Alerta ficticia para validar las reglas de integridad'
    )
    RETURNING id_alerta INTO v_alerta;

    -- La resolución sin evidencia debe rechazarse.
    v_rejected := FALSE;
    BEGIN
        UPDATE ALERTA_TECNICA
        SET estado = 'RESUELTA'
        WHERE id_alerta = v_alerta;
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió resolver una alerta sin acción correctiva/verificación.';
    END IF;

    -- La evidencia se registra como actuaciones append-only.
    INSERT INTO ACTUACION_ALERTA (id_alerta, tipo_actuacion, descripcion)
    VALUES
        (v_alerta, 'ACCION_CORRECTIVA', 'Acción correctiva ficticia'),
        (v_alerta, 'VERIFICACION', 'Verificación ficticia de la corrección');

    UPDATE ALERTA_TECNICA
    SET estado = 'RESUELTA'
    WHERE id_alerta = v_alerta;

    -- Una alerta resuelta no puede acumular nuevas ocurrencias.
    v_rejected := FALSE;
    BEGIN
        UPDATE ALERTA_TECNICA
        SET numero_ocurrencias = numero_ocurrencias + 1,
            ultima_ocurrencia = clock_timestamp()
        WHERE id_alerta = v_alerta;
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitieron nuevas ocurrencias tras resolver la alerta.';
    END IF;

    -- Las actuaciones posteriores a la resolución se rechazan.
    v_rejected := FALSE;
    BEGIN
        INSERT INTO ACTUACION_ALERTA (id_alerta, tipo_actuacion, descripcion)
        VALUES (v_alerta, 'COMENTARIO', 'Comentario que debe rechazarse');
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió añadir actuaciones a una alerta resuelta.';
    END IF;

    -- La observación final solo se puede introducir al cerrar.
    v_rejected := FALSE;
    BEGIN
        UPDATE ALERTA_TECNICA
        SET observacion_final = 'No debe admitirse antes del cierre'
        WHERE id_alerta = v_alerta;
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió introducir observación final antes del cierre.';
    END IF;

    UPDATE ALERTA_TECNICA
    SET estado = 'CERRADA',
        observacion_final = 'Cierre validado por la batería de pruebas'
    WHERE id_alerta = v_alerta;

    -- La fecha de cierre tiene que haberse generado automáticamente.
    IF NOT EXISTS (
        SELECT 1 FROM ALERTA_TECNICA
        WHERE id_alerta = v_alerta
          AND fecha_resolucion IS NOT NULL
          AND fecha_cierre IS NOT NULL
          AND fecha_cierre >= fecha_resolucion
    ) THEN
        RAISE EXCEPTION 'TEST FALLIDO: las fechas de resolución/cierre no son coherentes.';
    END IF;

    -- Las alertas cerradas no se pueden eliminar físicamente.
    v_rejected := FALSE;
    BEGIN
        DELETE FROM ALERTA_TECNICA WHERE id_alerta = v_alerta;
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió eliminar físicamente una alerta cerrada.';
    END IF;

    -- La cronología de ocurrencias debe validarse en la propia tabla.
    v_rejected := FALSE;
    BEGIN
        INSERT INTO ALERTA_TECNICA (
            codigo, origen, severidad, descripcion,
            primera_ocurrencia, ultima_ocurrencia
        )
        VALUES (
            v_prefix || '_ALERTA_FECHAS',
            'TEST',
            'INFO',
            'Alerta con fechas deliberadamente incoherentes',
            clock_timestamp() + INTERVAL '1 hour',
            clock_timestamp()
        );
    EXCEPTION WHEN check_violation THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se aceptó una última ocurrencia anterior a la primera.';
    END IF;

    -- --------------------------------------------------------
    -- 4. Avisos: deduplicación, archivo y reactivación
    -- --------------------------------------------------------
    INSERT INTO AVISO_SEGUIMIENTO (
        id_incidente, origen, clave_deduplicacion
    )
    VALUES (
        v_incidente, 'AUTOMATICO', v_prefix || '_AVISO'
    )
    RETURNING id_aviso INTO v_aviso;

    -- La clave automática no puede estar vacía.
    v_rejected := FALSE;
    BEGIN
        INSERT INTO AVISO_SEGUIMIENTO (
            id_incidente, origen, clave_deduplicacion
        )
        VALUES (v_incidente, 'AUTOMATICO', '   ');
    EXCEPTION WHEN check_violation THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se aceptó una clave de deduplicación vacía.';
    END IF;

    -- La clave de deduplicación debe ser única.
    v_rejected := FALSE;
    BEGIN
        INSERT INTO AVISO_SEGUIMIENTO (
            id_incidente, origen, clave_deduplicacion
        )
        VALUES (v_incidente, 'AUTOMATICO', v_prefix || '_AVISO');
    EXCEPTION WHEN unique_violation THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió duplicar la clave de un aviso automático.';
    END IF;

    UPDATE AVISO_SEGUIMIENTO
    SET estado = 'CANCELADO'
    WHERE id_aviso = v_aviso;

    UPDATE AVISO_SEGUIMIENTO
    SET activo = FALSE
    WHERE id_aviso = v_aviso;

    -- Un aviso archivado no puede modificarse.
    v_rejected := FALSE;
    BEGIN
        UPDATE AVISO_SEGUIMIENTO
        SET descripcion = 'Modificación no permitida'
        WHERE id_aviso = v_aviso;
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió modificar un aviso archivado.';
    END IF;

    -- Reactivar un aviso terminal conserva el resto de sus datos.
    UPDATE AVISO_SEGUIMIENTO
    SET activo = TRUE
    WHERE id_aviso = v_aviso;

    IF NOT EXISTS (
        SELECT 1 FROM AVISO_SEGUIMIENTO
        WHERE id_aviso = v_aviso
          AND activo = TRUE
          AND estado = 'CANCELADO'
    ) THEN
        RAISE EXCEPTION 'TEST FALLIDO: no se pudo reactivar el aviso terminal sin alterar sus datos.';
    END IF;

    -- --------------------------------------------------------
    -- 5. Ejecuciones: finalización, detalle de fallo e inmutabilidad
    -- --------------------------------------------------------
    INSERT INTO EJECUCION_PROCESO (
        codigo_proceso, identificador_ejecucion, estado
    )
    VALUES (
        v_prefix || '_PROCESO',
        v_prefix || '_RUN_OK',
        'EN_EJECUCION'
    )
    RETURNING id_ejecucion INTO v_ejecucion;

    UPDATE EJECUCION_PROCESO
    SET estado = 'COMPLETADA'
    WHERE id_ejecucion = v_ejecucion;

    SELECT fecha_fin INTO v_fecha_fin
    FROM EJECUCION_PROCESO
    WHERE id_ejecucion = v_ejecucion;

    IF v_fecha_fin IS NULL THEN
        RAISE EXCEPTION 'TEST FALLIDO: no se generó fecha_fin al completar la ejecución.';
    END IF;

    v_rejected := FALSE;
    BEGIN
        UPDATE EJECUCION_PROCESO
        SET detalle_error = 'Cambio posterior a la finalización'
        WHERE id_ejecucion = v_ejecucion;
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió modificar una ejecución finalizada.';
    END IF;

    v_rejected := FALSE;
    BEGIN
        DELETE FROM EJECUCION_PROCESO
        WHERE id_ejecucion = v_ejecucion;
    EXCEPTION WHEN raise_exception THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió borrar una ejecución.';
    END IF;

    -- Una ejecución fallida debe guardar un motivo no vacío.
    INSERT INTO EJECUCION_PROCESO (
        codigo_proceso, identificador_ejecucion, estado
    )
    VALUES (
        v_prefix || '_PROCESO',
        v_prefix || '_RUN_FAIL',
        'EN_EJECUCION'
    )
    RETURNING id_ejecucion INTO v_ejecucion;

    v_rejected := FALSE;
    BEGIN
        UPDATE EJECUCION_PROCESO
        SET estado = 'FALLIDA',
            detalle_error = '   '
        WHERE id_ejecucion = v_ejecucion;
    EXCEPTION WHEN check_violation THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se permitió finalizar como FALLIDA sin detalle de error.';
    END IF;

    UPDATE EJECUCION_PROCESO
    SET estado = 'FALLIDA',
        detalle_error = 'Error ficticio capturado por la prueba'
    WHERE id_ejecucion = v_ejecucion;

    IF NOT EXISTS (
        SELECT 1 FROM EJECUCION_PROCESO
        WHERE id_ejecucion = v_ejecucion
          AND estado = 'FALLIDA'
          AND fecha_fin IS NOT NULL
          AND BTRIM(detalle_error) <> ''
    ) THEN
        RAISE EXCEPTION 'TEST FALLIDO: no se guardó correctamente el detalle de fallo.';
    END IF;

    -- --------------------------------------------------------
    -- 6. Auditoría: snapshots JSONB de tipo objeto
    -- --------------------------------------------------------
    INSERT INTO AUDITORIA (
        origen, entidad, id_registro, accion,
        valores_anteriores, valores_nuevos
    )
    VALUES (
        'SISTEMA', 'INCIDENTE', v_incidente, 'STATE_CHANGE',
        '{"estado":"REGISTRADO"}'::JSONB,
        '{"estado":"EN_GESTION"}'::JSONB
    );

    v_rejected := FALSE;
    BEGIN
        INSERT INTO AUDITORIA (
            origen, entidad, id_registro, accion,
            valores_anteriores, valores_nuevos
        )
        VALUES (
            'SISTEMA', 'INCIDENTE', v_incidente, 'STATE_CHANGE',
            '[]'::JSONB,
            '{"estado":"EN_GESTION"}'::JSONB
        );
    EXCEPTION WHEN check_violation THEN
        v_rejected := TRUE;
    END;
    IF NOT v_rejected THEN
        RAISE EXCEPTION 'TEST FALLIDO: se aceptó un snapshot JSONB que no es un objeto.';
    END IF;

    RAISE NOTICE 'OK: todas las pruebas estructurales y funcionales han terminado correctamente.';
END;
$tests$;

-- Las inserciones de prueba se revierten. Ejecutar en una BD aislada
-- sigue siendo obligatorio porque CREATE DATABASE/esquema no se prueba aquí.
ROLLBACK;
