# Pruebas del esquema S.A.P.O.

## Orden de ejecución

1. Crear una base de datos temporal vacía con PostgreSQL 18.7 (el flujo de CI lo hace automáticamente).
2. Ejecutar en ella el esquema canónico versionado:
   `database/schema/SAPO_SCHEMA.sql`.
3. Si la creación completa finaliza correctamente, ejecutar:
   `database/tests/TEST_REGLAS_INTEGRIDAD.sql`.
4. Comprobar que pgAdmin muestra el aviso:
   `OK: todas las pruebas estructurales y funcionales han terminado correctamente.`
5. La ejecución automática superada está registrada en [GitHub Actions #6](https://github.com/Zanguango/SAPO/actions/runs/45885898980) y en la tarea técnica [#55](https://github.com/Zanguango/SAPO/issues/55).

## Qué comprueba

La batería verifica el inventario base actualizado (24 tablas, 31 claves foráneas, 38 índices explícitos, 48 triggers y 37 nombres de funciones propias) y reglas críticas de:

- Alertas técnicas: evidencia previa a resolución, append-only de actuaciones, cierre con observación, cronología y bloqueo de borrado físico.
- Avisos: clave de deduplicación no vacía y única, archivo únicamente desde estado terminal y reactivación sin alterar el histórico.
- Ejecuciones: fecha de fin automática, inmutabilidad tras finalizar y detalle obligatorio si la ejecución falla.
- Auditoría: snapshots JSONB con estructura de objeto.

Las pruebas positivas y negativas se ejecutan dentro de una transacción y terminan con `ROLLBACK`. No dejan registros de prueba persistentes, aunque los valores de secuencias de identidad pueden avanzar.

- Avisos de seguimiento: deduplicación, archivo/reactivación, fecha de gestión y rechazo del borrado físico.
- Personas: rechazo de modificaciones después del archivo y restauración permitida solo mediante el cambio de `activo`, sin alterar sus datos.
- Archivo lógico: rechazo del borrado físico de organización, usuario, persona, incidente, antecedente y ubicación.
- Concurrencia: comprobación de que el SQL utiliza bloqueos de fila apropiados al validar catálogos y transiciones.

## Límites

Esta batería no sustituye las pruebas unitarias del backend, las pruebas de permisos ni la validación de todos los caminos del modelo. Tampoco demuestra por sí sola que el esquema coincida con la instancia local. Su ejecución debe hacerse exclusivamente en la base temporal; **no ejecutar el esquema canónico ni la batería de pruebas sobre `sapo_db`**.

Las pruebas funcionales también verifican que una alerta resuelta/cerrada no admita cambios de contenido, que una actuación no sea anterior a la primera ocurrencia, que el responsable de un aviso esté activo y que la fecha de gestión no preceda a la creación.

## Diagnóstico de solo lectura de la instancia local

El script `database/diagnostics/AUDITAR_ESQUEMA_LOCAL_SOLO_LECTURA.sql` obtiene metadatos del esquema `public`; no consulta filas de negocio ni modifica datos u objetos. Incluye columnas, tipos, longitudes, precisión, valores por defecto, nulabilidad, restricciones, índices, triggers, funciones propias `fn_*` y extensiones.

El flujo de CI ejecuta también este diagnóstico en la base temporal `sapo_ci` después de instalar el esquema canónico. La ejecución [#10](https://github.com/Zanguango/SAPO/actions/runs/45886924060) terminó correctamente. Esta validación comprueba la sintaxis y salida del diagnóstico, pero no sustituye la exportación de metadatos de la instancia local.

Para completar la tarea #56, ejecutar únicamente el script de diagnóstico en pgAdmin seleccionando `sapo_db` y exportar su resultado como CSV. **No ejecutar `SAPO_SCHEMA.sql` ni las pruebas de integridad sobre `sapo_db`.**
