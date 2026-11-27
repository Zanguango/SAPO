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


## Comprobación de datos antes de una migración

El script `database/diagnostics/VERIFICAR_COMPATIBILIDAD_DATOS_PRE_MIGRACION_SOLO_LECTURA.sql` comprueba si los datos existentes podrían incumplir restricciones CHECK ausentes o reforzadas en el esquema canónico. Para cada regla devuelve el número de filas incompatibles y hasta cinco identificadores de ejemplo.

- Es una consulta de solo lectura: no modifica filas, restricciones ni otros objetos.
- Ejecutar seleccionando la base `sapo_db` únicamente después de confirmar que el script abierto corresponde a esta ruta.
- Un recuento cero significa que no se encontraron filas incompatibles con las reglas comprobadas; no valida funciones, triggers, permisos ni todos los casos de negocio.
- La ejecución [GitHub Actions #13](https://github.com/Zanguango/SAPO/actions/runs/46000080191) validó el script en la base CI vacía, por lo que sus ceros no deben interpretarse como resultado de `sapo_db`.
- No ejecutar el esquema canónico ni la batería de pruebas sobre `sapo_db`.

La verificación real de datos debe preceder a cualquier ensayo de migración. El ensayo se realizará sobre una copia restaurada aislada, preservando los catálogos locales y sus identificadores.

## Verificación de una copia restaurada

El script `database/diagnostics/VERIFICAR_COPIA_RESTAURADA_SAPO_SOLO_LECTURA.sql` devuelve en una sola salida la base consultada, los recuentos de las 24 tablas y los identificadores/nombres de los catálogos principales (organización, tipos de incidente, perfiles, estados y transiciones). Se ejecuta por separado en `sapo_db` y en `sapo_db_migracion_prueba`; los resultados deben coincidir antes de ensayar la migración. No consulta registros personales ni operativos y no modifica datos u objetos.

El flujo de CI también ejecuta el script sobre `sapo_ci`, una base temporal creada desde cero. Esta comprobación valida sintaxis y compatibilidad con el esquema canónico, pero no sustituye la comparación real entre la base local y su restauración. El procedimiento completo está en [`docs/MIGRACION_CONTROLADA_SAPO_DB.md`](../../docs/MIGRACION_CONTROLADA_SAPO_DB.md).
