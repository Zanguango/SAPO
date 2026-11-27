-- S.A.P.O. - Compatibilidad de datos antes de una posible migración (SOLO LECTURA)
-- Ejecutar en pgAdmin Query Tool seleccionando la base sapo_db.
-- No realiza INSERT, UPDATE, DELETE, DDL ni cambia la configuración.
-- Solo consulta filas para detectar si incumplen reglas que el esquema canónico
-- incorpora y que todavía no están aplicadas en la instancia local.
--
-- Devuelve un único resultado con una fila por regla:
-- violation_count = 0: no se han encontrado filas incompatibles con esa regla.
-- violation_count > 0: revisar los ejemplos antes de añadir la restricción.
-- Se muestran como máximo cinco identificadores de ejemplo por regla.
--
-- Esta consulta no acredita compatibilidad de funciones, triggers o concurrencia.
-- Tampoco autoriza a ejecutar SAPO_SCHEMA.sql sobre sapo_db.

WITH rules(rule_code, table_name) AS (
    VALUES
        ('CK_AVISO_FECHA_GESTION', 'AVISO_SEGUIMIENTO'),
        ('CK_AUDITORIA_SNAPSHOTS_OBJETO', 'AUDITORIA'),
        ('CK_EJECUCION_CODIGO', 'EJECUCION_PROCESO'),
        ('CK_EJECUCION_IDENTIFICADOR', 'EJECUCION_PROCESO'),
        ('CK_EJECUCION_ERROR_FALLIDA', 'EJECUCION_PROCESO'),
        ('CK_ALERTA_TEXTO', 'ALERTA_TECNICA'),
        ('CK_ALERTA_OCURRENCIA_CRONOLOGIA', 'ALERTA_TECNICA'),
        ('CK_ALERTA_ESTADO_FECHAS', 'ALERTA_TECNICA'),
        ('CK_ALERTA_OBSERVACION_FINAL', 'ALERTA_TECNICA'),
        ('CK_ACTUACION_DESCRIPCION', 'ACTUACION_ALERTA'),
        ('CK_ALERTA_FECHAS_CRONOLOGIA', 'ALERTA_TECNICA'),
        ('CK_AVISO_CLAVE_DEDUPLICACION_NO_VACIA', 'AVISO_SEGUIMIENTO')
),
violations(rule_code, record_id, detail) AS (
    SELECT
        'CK_AVISO_FECHA_GESTION',
        id_aviso::text,
        'fecha_gestion anterior a fecha_creacion'
    FROM AVISO_SEGUIMIENTO
    WHERE fecha_gestion IS NOT NULL
      AND fecha_gestion < fecha_creacion

    UNION ALL

    SELECT
        'CK_AUDITORIA_SNAPSHOTS_OBJETO',
        id_auditoria::text,
        'valores_anteriores o valores_nuevos no es un objeto JSON'
    FROM AUDITORIA
    WHERE (valores_anteriores IS NOT NULL
           AND jsonb_typeof(valores_anteriores) IS DISTINCT FROM 'object')
       OR (valores_nuevos IS NOT NULL
           AND jsonb_typeof(valores_nuevos) IS DISTINCT FROM 'object')

    UNION ALL

    SELECT
        'CK_EJECUCION_CODIGO',
        id_ejecucion::text,
        'codigo_proceso vacío o compuesto por espacios'
    FROM EJECUCION_PROCESO
    WHERE BTRIM(codigo_proceso) = ''

    UNION ALL

    SELECT
        'CK_EJECUCION_IDENTIFICADOR',
        id_ejecucion::text,
        'identificador_ejecucion vacío o compuesto por espacios'
    FROM EJECUCION_PROCESO
    WHERE identificador_ejecucion IS NOT NULL
      AND BTRIM(identificador_ejecucion) = ''

    UNION ALL

    SELECT
        'CK_EJECUCION_ERROR_FALLIDA',
        id_ejecucion::text,
        'ejecución FALLIDA sin detalle_error útil'
    FROM EJECUCION_PROCESO
    WHERE estado = 'FALLIDA'
      AND (detalle_error IS NULL OR BTRIM(detalle_error) = '')

    UNION ALL

    SELECT
        'CK_ALERTA_TEXTO',
        id_alerta::text,
        'codigo, origen o descripcion vacío'
    FROM ALERTA_TECNICA
    WHERE BTRIM(codigo) = ''
       OR BTRIM(origen) = ''
       OR BTRIM(descripcion) = ''

    UNION ALL

    SELECT
        'CK_ALERTA_OCURRENCIA_CRONOLOGIA',
        id_alerta::text,
        'ultima_ocurrencia anterior a primera_ocurrencia'
    FROM ALERTA_TECNICA
    WHERE ultima_ocurrencia < primera_ocurrencia

    UNION ALL

    SELECT
        'CK_ALERTA_ESTADO_FECHAS',
        id_alerta::text,
        'combinación de estado, fecha_resolucion y fecha_cierre no válida'
    FROM ALERTA_TECNICA
    WHERE NOT (
        (
            estado IN ('NUEVA', 'EN_REVISION')
            AND fecha_resolucion IS NULL
            AND fecha_cierre IS NULL
        )
        OR
        (
            estado = 'RESUELTA'
            AND fecha_resolucion IS NOT NULL
            AND fecha_cierre IS NULL
        )
        OR
        (
            estado = 'CERRADA'
            AND fecha_resolucion IS NOT NULL
            AND fecha_cierre IS NOT NULL
        )
    )

    UNION ALL

    SELECT
        'CK_ALERTA_OBSERVACION_FINAL',
        id_alerta::text,
        'observacion_final contiene solo espacios'
    FROM ALERTA_TECNICA
    WHERE observacion_final IS NOT NULL
      AND BTRIM(observacion_final) = ''

    UNION ALL

    SELECT
        'CK_ACTUACION_DESCRIPCION',
        id_actuacion::text,
        'descripcion vacía o compuesta por espacios'
    FROM ACTUACION_ALERTA
    WHERE BTRIM(descripcion) = ''

    UNION ALL

    SELECT
        'CK_ALERTA_FECHAS_CRONOLOGIA',
        id_alerta::text,
        'fecha_cierre anterior a fecha_resolucion'
    FROM ALERTA_TECNICA
    WHERE fecha_cierre IS NOT NULL
      AND fecha_resolucion IS NOT NULL
      AND fecha_cierre < fecha_resolucion

    UNION ALL

    SELECT
        'CK_AVISO_CLAVE_DEDUPLICACION_NO_VACIA',
        id_aviso::text,
        'aviso AUTOMATICO con clave_deduplicacion vacía o compuesta por espacios'
    FROM AVISO_SEGUIMIENTO
    WHERE origen = 'AUTOMATICO'
      AND clave_deduplicacion IS NOT NULL
      AND BTRIM(clave_deduplicacion) = ''
),
ranked_violations AS (
    SELECT
        rule_code,
        record_id,
        detail,
        ROW_NUMBER() OVER (
            PARTITION BY rule_code
            ORDER BY record_id
        ) AS sample_number
    FROM violations
),
aggregated AS (
    SELECT
        rule_code,
        COUNT(*) AS violation_count,
        STRING_AGG(
            CASE
                WHEN sample_number <= 5
                THEN record_id || ' (' || detail || ')'
            END,
            '; ' ORDER BY sample_number
        ) AS example_records
    FROM ranked_violations
    GROUP BY rule_code
)
SELECT
    r.rule_code,
    r.table_name,
    COALESCE(a.violation_count, 0) AS violation_count,
    CASE
        WHEN COALESCE(a.violation_count, 0) = 0 THEN 'OK'
        ELSE 'REVISAR'
    END AS result,
    COALESCE(a.example_records, '<ninguno>') AS example_records
FROM rules r
LEFT JOIN aggregated a
    ON a.rule_code = r.rule_code
ORDER BY r.rule_code;
