-- S.A.P.O. - Diagnóstico de esquema PostgreSQL (SOLO LECTURA)
-- Ejecutar en pgAdmin Query Tool seleccionando la base sapo_db.
-- No realiza INSERT, UPDATE, DELETE, DDL ni cambia la configuración.
-- Consulta únicamente catálogos y vistas de metadatos del esquema public.
-- No consulta filas de PERSONA, INCIDENTE ni de ningún otro dato operativo.
-- Exportar el único resultado como CSV para compararlo con database/schema/SAPO_SCHEMA.sql.
--
-- Esta versión amplía el detalle de columnas:
-- longitud máxima de texto, precisión/escala numérica, precisión temporal,
-- dominios, collation, valores por defecto e identidad/generación.

WITH objects AS (
    SELECT
        'SUMMARY'::text AS object_type,
        'database'::text AS object_key,
        current_database() || ' | PostgreSQL ' || current_setting('server_version') AS definition

    UNION ALL

    SELECT 'SUMMARY', 'tables',
           COUNT(*)::text
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public'
      AND c.relkind IN ('r', 'p')

    UNION ALL

    SELECT 'SUMMARY', 'foreign_keys',
           COUNT(*)::text
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND c.contype = 'f'

    UNION ALL

    SELECT 'SUMMARY', 'indexes',
           COUNT(*)::text
    FROM pg_indexes
    WHERE schemaname = 'public'

    UNION ALL

    SELECT 'SUMMARY', 'triggers',
           COUNT(*)::text
    FROM pg_trigger tr
    JOIN pg_class t ON t.oid = tr.tgrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND NOT tr.tgisinternal

    UNION ALL

    SELECT 'SUMMARY', 'function_definitions',
           COUNT(*)::text
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'
      AND left(p.proname, 3) = 'fn_'

    UNION ALL

    SELECT 'SUMMARY', 'distinct_function_names',
           COUNT(DISTINCT p.proname)::text
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'

    UNION ALL

    SELECT 'SUMMARY', 'btree_gist_extension',
           COALESCE(
               (SELECT extversion
                FROM pg_extension
                WHERE extname = 'btree_gist'),
               'NOT INSTALLED'
           )

    UNION ALL

    SELECT
        'TABLE_COLUMN',
        format('%I.%I.%I', c.table_schema, c.table_name, c.column_name),
        format(
            'ordinal=%s; data_type=%s; udt=%s.%s; domain=%s; char_max=%s; char_octets=%s; numeric_precision=%s; numeric_scale=%s; datetime_precision=%s; interval_type=%s; nullable=%s; default=%s; identity=%s; identity_start=%s; identity_increment=%s; identity_minimum=%s; identity_maximum=%s; identity_cycle=%s; generated=%s; generation_expression=%s; collation=%s.%s',
            c.ordinal_position,
            c.data_type,
            c.udt_schema,
            c.udt_name,
            COALESCE(c.domain_schema || '.' || c.domain_name, '<none>'),
            COALESCE(c.character_maximum_length::text, '<none>'),
            COALESCE(c.character_octet_length::text, '<none>'),
            COALESCE(c.numeric_precision::text, '<none>'),
            COALESCE(c.numeric_scale::text, '<none>'),
            COALESCE(c.datetime_precision::text, '<none>'),
            COALESCE(c.interval_type, '<none>'),
            c.is_nullable,
            COALESCE(c.column_default, '<none>'),
            COALESCE(c.identity_generation, '<none>'),
            COALESCE(c.identity_start, '<none>'),
            COALESCE(c.identity_increment, '<none>'),
            COALESCE(c.identity_minimum, '<none>'),
            COALESCE(c.identity_maximum, '<none>'),
            COALESCE(c.identity_cycle, '<none>'),
            c.is_generated,
            COALESCE(c.generation_expression, '<none>'),
            COALESCE(c.collation_schema, '<none>'),
            COALESCE(c.collation_name, '<none>')
        )
    FROM information_schema.columns c
    WHERE c.table_schema = 'public'
      AND c.table_name IN (
          SELECT t.table_name
          FROM information_schema.tables t
          WHERE t.table_schema = 'public'
            AND t.table_type = 'BASE TABLE'
      )

    UNION ALL

    SELECT
        'CONSTRAINT',
        format('%I.%I.%I', n.nspname, t.relname, c.conname),
        pg_get_constraintdef(c.oid, TRUE)
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'

    UNION ALL

    SELECT
        'INDEX',
        format('%I.%I', schemaname, indexname),
        indexdef
    FROM pg_indexes
    WHERE schemaname = 'public'

    UNION ALL

    SELECT
        'TRIGGER',
        format('%I.%I', n.nspname, tr.tgname),
        format(
            'enabled=%s; function=%s; definition=%s',
            CASE tr.tgenabled
                WHEN 'O' THEN 'ORIGIN'
                WHEN 'D' THEN 'DISABLED'
                WHEN 'R' THEN 'REPLICA'
                WHEN 'A' THEN 'ALWAYS'
                ELSE tr.tgenabled::text
            END,
            tr.tgfoid::regprocedure,
            pg_get_triggerdef(tr.oid, TRUE)
        )
    FROM pg_trigger tr
    JOIN pg_class t ON t.oid = tr.tgrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public'
      AND NOT tr.tgisinternal

    UNION ALL

    SELECT
        'FUNCTION',
        format(
            '%I.%I(%s)',
            n.nspname,
            p.proname,
            pg_get_function_identity_arguments(p.oid)
        ),
        pg_get_functiondef(p.oid)
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
      AND p.prokind = 'f'
      AND left(p.proname, 3) = 'fn_'

    UNION ALL

    SELECT
        'EXTENSION',
        e.extname,
        e.extversion
    FROM pg_extension e
)
SELECT object_type, object_key, definition
FROM objects
ORDER BY object_type, object_key;
