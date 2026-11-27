# Ensayo de migración controlada de `sapo_db`

**Proyecto:** S.A.P.O. — 47GIIN  
**Motor de referencia:** PostgreSQL 18.7  
**Base original:** `sapo_db`  
**Copia de ensayo:** `sapo_db_migracion_prueba`

## 1. Objetivo y estado actual

Este procedimiento prepara una copia restaurada de la base local para ensayar una futura migración incremental hacia el esquema canónico de `database/schema/SAPO_SCHEMA.sql`.

El diagnóstico real de compatibilidad de datos ejecutado el 27/11/2026 sobre `sapo_db` devolvió **12 reglas OK y 0 filas incompatibles**. Esto cubre las restricciones CHECK nuevas o reforzadas consultadas por el script; no valida por sí solo funciones, triggers, permisos ni todos los comportamientos.

La comparación estructural previa encontró coincidencia en las 24 tablas, 187 columnas, tipos/longitudes/precisión, valores por defecto, 31 claves foráneas y 71 índices de catálogo. Persisten diferencias de CHECK, triggers y funciones descritas en [DATABASE_DESIGN.md](DATABASE_DESIGN.md).

**No se debe ejecutar el esquema canónico completo ni una migración sobre `sapo_db`.** La base original se conserva intacta. El único destino permitido para el ensayo es la copia `sapo_db_migracion_prueba`.

## 2. Reglas de seguridad

- Usar únicamente datos ficticios del prototipo académico.
- No ejecutar DDL, pruebas ni scripts de migración en `sapo_db`.
- No borrar, recrear ni renombrar la base original.
- No sustituir la copia por una base creada desde cero: debe ser una restauración de la base original.
- No ejecutar `SAPO_SCHEMA.sql` sobre la copia restaurada: se preparará un script incremental específico.
- No subir archivos `.backup`, volcados SQL ni datos de la base al repositorio Git.
- Si pgAdmin muestra errores de propietario, extensión o restauración, detenerse y conservar el mensaje exacto; no improvisar opciones.

## 3. Crear una copia de seguridad de `sapo_db`

En pgAdmin 4:

1. En el árbol del servidor PostgreSQL 18, localiza **Databases → sapo_db**.
2. Pulsa con el botón derecho sobre `sapo_db` y selecciona **Backup…**.
3. En **General**, elige una ruta local fuera del repositorio, por ejemplo `C:\SAPO_BACKUPS\sapo_db_pre_migracion_20261127.backup`. Crea previamente la carpeta si no existe.
4. Selecciona el formato **Custom**.
5. En las opciones de volcado, incluye el esquema y los datos. No selecciones opciones equivalentes a **Only schema** ni **Only data**; deben incluirse las secciones pre-data, data y post-data.
6. Inicia el backup y comprueba que pgAdmin termina sin errores y que el archivo existe y tiene tamaño distinto de cero.

Este archivo es la copia de seguridad de referencia. No lo edites ni lo guardes dentro del repositorio.

## 4. Crear y restaurar la base aislada

1. En **Databases**, selecciona **Create → Database…**.
2. Nombre: `sapo_db_migracion_prueba`.
3. Propietario: el mismo rol local que administra `sapo_db`, siempre que esté disponible.
4. Crea la base vacía. No uses `sapo_db` como destino.
5. Pulsa con el botón derecho sobre `sapo_db_migracion_prueba` y selecciona **Restore…**.
6. Selecciona el archivo `.backup` recién generado y el formato **Custom**.
7. Restaura esquema y datos completos en la base vacía. No actives opciones de limpieza de objetos existentes.
8. Espera al resultado de pgAdmin. Si hay errores de roles, propietario o extensiones, detén el proceso y guarda el mensaje completo para revisarlo antes de continuar.

La restauración tiene que crear una copia de los objetos y filas que había en `sapo_db`; no debe crear una versión vacía del esquema canónico.

## 5. Comprobar la copia antes de migrar

Abre un Query Tool independiente en cada base y ejecuta únicamente:

`database/diagnostics/VERIFICAR_COPIA_RESTAURADA_SAPO_SOLO_LECTURA.sql`

Ejecuta primero en `sapo_db` y después en `sapo_db_migracion_prueba`. Guarda los dos CSV y compáralos.

Criterios mínimos:

- La primera fila debe identificar la base consultada correctamente.
- Deben aparecer los recuentos de las 24 tablas y coincidir entre origen y copia.
- Debe conservarse la organización local y los siete tipos de incidente.
- Los identificadores, nombres y estados de organización, tipos de incidente, perfiles, estados y transiciones deben coincidir entre ambas salidas.
- Los recuentos conocidos antes de la copia son: 1 organización, 7 tipos de incidente, 4 estados y 5 transiciones.
- El diagnóstico de metadatos de solo lectura debe seguir mostrando, antes de migrar, el mismo inventario local: 24 tablas, 187 columnas, 31 FK, 71 índices, 42 triggers y 36 funciones propias.

**No continúes** si falta una fila, cambia un identificador de catálogo o difiere un recuento. Primero debe resolverse la calidad de la copia.

## 6. Preparar el ensayo incremental

Una vez validada la restauración:

1. Crear un segundo backup de `sapo_db_migracion_prueba` con un nombre que identifique que es la copia previa a la migración.
2. Preparar y revisar un script incremental específico para el esquema local. El script debe comprobar al inicio que `current_database()` es `sapo_db_migracion_prueba` y abortar ante cualquier otro nombre.
3. Aplicar los cambios solo en esa copia. El alcance esperado comprende las CHECK ausentes o menos restrictivas, la función común de bloqueo de borrado físico, los seis triggers de protección, los dos eventos de trigger distintos y las funciones cuyo comportamiento difiere del canónico.
4. No recrear tablas, columnas, claves foráneas ni índices que ya coinciden.
5. Ejecutar `database/tests/TEST_REGLAS_INTEGRIDAD.sql` únicamente después de aplicar y revisar el script incremental. La batería abre una transacción y termina con `ROLLBACK`; los valores de secuencias de identidad pueden avanzar aunque las filas de prueba se reviertan.
6. Repetir el diagnóstico de metadatos y la consulta de recuentos/catálogos. Verificar los 50 CHECK, 48 triggers, 37 nombres de funciones propias y que los datos originales continúan presentes.
7. Documentar incidencias, resultado y evidencia antes de decidir si existe un plan de migración aceptable.

No se considera superado el ensayo solo porque el script termine sin errores: deben superarse también las comprobaciones estructurales y funcionales y conservarse los datos.

## 7. Decisión después del ensayo

- **Éxito:** documentar el procedimiento y dejar `sapo_db` original intacta. Cualquier aplicación posterior sobre la instancia original requerirá autorización expresa y una ventana de trabajo independiente.
- **Fallo:** descartar la copia de ensayo y restaurar de nuevo el backup en otra base aislada. No intentar una reversión improvisada ni tocar la instancia original.

## 8. Evidencias que deben conservarse

- Archivo de backup original y resultado satisfactorio del backup (fuera de Git).
- CSV de `VERIFICAR_COPIA_RESTAURADA_SAPO_SOLO_LECTURA.sql` para origen y copia.
- Resultado de restauración de pgAdmin.
- Script incremental revisado y commit que lo versiona.
- Resultado de `TEST_REGLAS_INTEGRIDAD.sql`.
- CSV de metadatos y comprobación posterior de recuentos/catálogos.
- Conclusión y decisión registradas en la tarea técnica [#56](https://github.com/Zanguango/SAPO/issues/56).
