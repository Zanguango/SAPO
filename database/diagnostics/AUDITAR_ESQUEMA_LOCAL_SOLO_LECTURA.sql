-- S.A.P.O. - Diagnóstico de esquema PostgreSQL (SOLO LECTURA)
-- Ejecutar en pgAdmin Query Tool seleccionando la base sapo_db.
-- No realiza INSERT, UPDATE, DELETE, DDL ni cambia la configuración.
-- Devuelve metadatos del esquema public; no consulta filas de PERSONA ni INCIDENTE.
-- Exportar el único resultado como CSV para compararlo con el SQL candidato.

WITH objects AS (
    SELECT
        'SUMMARY'::text AS object_type,
        'database'::text AS object_key,
        current_database() || ' | ' || current_setting('server_version') AS definition

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
            'ordinal=%s; type=%s; udt=%s; nullable=%s; default=%s; identity=%s',
            c.ordinal_position,
            c.data_type,
            c.udt_name,
            c.is_nullable,
            COALESCE(c.column_default, '<none>'),
            COALESCE(c.identity_generation, '<none>')
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
        pg_get_triggerdef(tr.oid, TRUE)
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
