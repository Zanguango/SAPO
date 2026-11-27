-- S.A.P.O. - Verificación de copia restaurada (SOLO LECTURA)
-- Ejecutar por separado en sapo_db y sapo_db_migracion_prueba.
-- Devuelve una sola cuadrícula para exportar y comparar entre las dos bases.
-- No realiza INSERT, UPDATE, DELETE, DDL ni cambia la configuración.
-- Muestra recuentos de todas las tablas y datos de catálogos ficticios,
-- incluyendo identificadores para comprobar que la restauración los conserva.
-- No consulta datos personales ni registros operativos individuales.

WITH snapshot(tipo, elemento, valor, detalle) AS (
    SELECT 'ENTORNO'::text, 'BASE_DATOS'::text,
           current_database()::text, version()::text

    UNION ALL SELECT 'RECUENTO', 'ORGANIZACION', COUNT(*)::text, NULL::text FROM ORGANIZACION
    UNION ALL SELECT 'RECUENTO', 'UNIDAD_ORGANIZATIVA', COUNT(*)::text, NULL::text FROM UNIDAD_ORGANIZATIVA
    UNION ALL SELECT 'RECUENTO', 'PERFIL', COUNT(*)::text, NULL::text FROM PERFIL
    UNION ALL SELECT 'RECUENTO', 'USUARIO', COUNT(*)::text, NULL::text FROM USUARIO
    UNION ALL SELECT 'RECUENTO', 'HISTORIAL_PERTENENCIA_ORGANIZATIVA', COUNT(*)::text, NULL::text FROM HISTORIAL_PERTENENCIA_ORGANIZATIVA
    UNION ALL SELECT 'RECUENTO', 'HISTORIAL_UNIDAD_USUARIO', COUNT(*)::text, NULL::text FROM HISTORIAL_UNIDAD_USUARIO
    UNION ALL SELECT 'RECUENTO', 'HISTORIAL_PERFIL_USUARIO', COUNT(*)::text, NULL::text FROM HISTORIAL_PERFIL_USUARIO
    UNION ALL SELECT 'RECUENTO', 'PERSONA', COUNT(*)::text, NULL::text FROM PERSONA
    UNION ALL SELECT 'RECUENTO', 'TIPO_ANTECEDENTE', COUNT(*)::text, NULL::text FROM TIPO_ANTECEDENTE
    UNION ALL SELECT 'RECUENTO', 'ANTECEDENTE', COUNT(*)::text, NULL::text FROM ANTECEDENTE
    UNION ALL SELECT 'RECUENTO', 'TIPO_INCIDENTE', COUNT(*)::text, NULL::text FROM TIPO_INCIDENTE
    UNION ALL SELECT 'RECUENTO', 'ESTADO_INCIDENTE', COUNT(*)::text, NULL::text FROM ESTADO_INCIDENTE
    UNION ALL SELECT 'RECUENTO', 'TRANSICION_ESTADO_INCIDENTE', COUNT(*)::text, NULL::text FROM TRANSICION_ESTADO_INCIDENTE
    UNION ALL SELECT 'RECUENTO', 'UBICACION', COUNT(*)::text, NULL::text FROM UBICACION
    UNION ALL SELECT 'RECUENTO', 'INCIDENTE', COUNT(*)::text, NULL::text FROM INCIDENTE
    UNION ALL SELECT 'RECUENTO', 'VINCULACION_PERSONA_INCIDENTE', COUNT(*)::text, NULL::text FROM VINCULACION_PERSONA_INCIDENTE
    UNION ALL SELECT 'RECUENTO', 'ASIGNACION_INCIDENTE', COUNT(*)::text, NULL::text FROM ASIGNACION_INCIDENTE
    UNION ALL SELECT 'RECUENTO', 'DOCUMENTO_ASOCIADO', COUNT(*)::text, NULL::text FROM DOCUMENTO_ASOCIADO
    UNION ALL SELECT 'RECUENTO', 'AVISO_SEGUIMIENTO', COUNT(*)::text, NULL::text FROM AVISO_SEGUIMIENTO
    UNION ALL SELECT 'RECUENTO', 'AUDITORIA', COUNT(*)::text, NULL::text FROM AUDITORIA
    UNION ALL SELECT 'RECUENTO', 'EJECUCION_PROCESO', COUNT(*)::text, NULL::text FROM EJECUCION_PROCESO
    UNION ALL SELECT 'RECUENTO', 'ALERTA_TECNICA', COUNT(*)::text, NULL::text FROM ALERTA_TECNICA
    UNION ALL SELECT 'RECUENTO', 'ACTUACION_ALERTA', COUNT(*)::text, NULL::text FROM ACTUACION_ALERTA
    UNION ALL SELECT 'RECUENTO', 'CONFIGURACION_UMBRAL', COUNT(*)::text, NULL::text FROM CONFIGURACION_UMBRAL

    UNION ALL
    SELECT 'CATALOGO', 'ORGANIZACION', id_organizacion::text,
           'nombre=' || nombre || '; activo=' || activo::text
    FROM ORGANIZACION

    UNION ALL
    SELECT 'CATALOGO', 'TIPO_INCIDENTE', id_tipo_incidente::text,
           'nombre=' || nombre || '; activo=' || activo::text
    FROM TIPO_INCIDENTE

    UNION ALL
    SELECT 'CATALOGO', 'PERFIL', id_perfil::text,
           'codigo=' || codigo || '; protegido=' || protegido::text || '; activo=' || activo::text
    FROM PERFIL

    UNION ALL
    SELECT 'CATALOGO', 'ESTADO_INCIDENTE', id_estado_incidente::text,
           'codigo=' || codigo || '; orden=' || orden_visualizacion::text
           || '; terminal=' || es_terminal::text || '; activo=' || activo::text
    FROM ESTADO_INCIDENTE

    UNION ALL
    SELECT 'CATALOGO', 'TRANSICION_ESTADO_INCIDENTE', t.id_transicion::text,
           origen.codigo || ' -> ' || destino.codigo || '; activo=' || t.activo::text
    FROM TRANSICION_ESTADO_INCIDENTE t
    JOIN ESTADO_INCIDENTE origen
      ON origen.id_estado_incidente = t.id_estado_origen
    JOIN ESTADO_INCIDENTE destino
      ON destino.id_estado_incidente = t.id_estado_destino
)
SELECT tipo, elemento, valor, detalle
FROM snapshot
ORDER BY tipo, elemento, valor;
