# Revisión comparativa de los scripts SQL — Sprint 1

**Fecha:** 26/11/2026  
**Responsable:** Ignacio Teruel Cuartero  
**Instancia local:** `sapo_db`, esquema `public`, PostgreSQL 18.7  
**Historia relacionada:** SAPO-003

## 1. Ficheros comparados

He contrastado los cuatro ficheros SQL disponibles:

| Archivo | SHA-256 |
|---|---|
| `SAPO.sql` | `0ace9ba92575c4a61a41859271cfd3d1e926ca4e84bea4658b5f3ac4bfa254c7` |
| `SAPO_CORREGIDO.sql` | `8be9fb7009b71f5fda9c6eec468b93b6542ae5d588007f23d468111259b3f455` |
| `SAPO_CORREGIDO(1).sql` | `8be9fb7009b71f5fda9c6eec468b93b6542ae5d588007f23d468111259b3f455` |
| `SAPO_CORREGIDO_REVISION_ESTATICA.sql` | `c90ce86ed8e20b1b31c1de7373ef6e2c2de452aed28fdbede7608c881877fcd4` |

Los ficheros `SAPO_CORREGIDO.sql` y `SAPO_CORREGIDO(1).sql` son idénticos byte a byte; no son revisiones diferentes.

## 2. Comparación estructural

| Objeto | `SAPO.sql` | `SAPO_CORREGIDO.sql` | `REVISION_ESTATICA.sql` |
|---|---:|---:|---:|
| Tablas | 24 | 24 | 24 |
| Claves foráneas | 31 | 31 | 31 |
| Índices declarados | 37 | 38 | 38 |
| Declaraciones de restricciones con nombre | 78 | 79 | 79 |
| Definiciones de función | 17 | 40 | 40 |
| Nombres distintos de función | 17 | 36 | 36 |
| Triggers | 22 | 42 | 42 |

Entre `SAPO_CORREGIDO.sql` y `SAPO_CORREGIDO_REVISION_ESTATICA.sql` he comprobado que las 24 definiciones de tabla, los nombres de los índices, las restricciones con nombre y los 42 nombres de triggers coinciden. Los dos scripts corregidos contienen 40 definiciones `CREATE OR REPLACE FUNCTION`, pero 36 nombres diferentes porque algunas funciones se redefinen dentro del propio script.

## 3. Cambios de la revisión estática

He localizado estos cambios en la comparación de los dos scripts corregidos:

1. **`fn_proteger_documento_asociado`**: se añade una comprobación que impide modificar un documento ya archivado.
2. **`fn_validar_transicion_incidente`**: se elimina `FOR UPDATE` de la subconsulta `EXISTS` que comprueba una transición permitida; el propio SQL revisado incluye un comentario explicativo.
3. **`fn_validar_vinculacion_persona_incidente`**: se separan los controles de alta y reactivación. En una nueva vinculación se comprueba que la persona esté activa y que el incidente exista, esté activo y no sea terminal.
4. **`trg_proteger_ejecucion_proceso`**: la protección pasa de `UPDATE OR DELETE` a `INSERT OR UPDATE OR DELETE` sobre `EJECUCION_PROCESO`.

Por estos cambios, utilizo `SAPO_CORREGIDO_REVISION_ESTATICA.sql` como referencia del análisis actual de funciones y triggers. Esto no demuestra que todos los objetos de la instancia local coincidan exactamente con ese fichero.

## 4. Inserciones de datos iniciales en los ficheros

He buscado todas las sentencias `INSERT INTO` de los cuatro ficheros. Solo hay inserciones para:
- `PERFIL`.
- `ESTADO_INCIDENTE`.
- `TRANSICION_ESTADO_INCIDENTE`.

No he encontrado inserciones para `ORGANIZACION`, `TIPO_INCIDENTE`, `UBICACION`, `PERSONA`, `INCIDENTE`, `USUARIO` ni `TIPO_ANTECEDENTE`.

## 5. Contraste con mi instancia local

El 26/11/2026 he ejecutado una consulta desde pgAdmin 4 conectado a `sapo_db`, esquema `public`:

| Indicador | Resultado local |
|---|---:|
| PostgreSQL | 18.7, 64 bits |
| Tablas | 24 |
| Claves foráneas | 31 |
| ORGANIZACION | 1 fila |
| TIPO_INCIDENTE | 7 filas |
| ESTADO_INCIDENTE | 4 filas |
| TRANSICION_ESTADO_INCIDENTE | 5 filas |
| PERSONA | 0 filas |
| INCIDENTE | 0 filas |

Los recuentos locales de tablas y claves foráneas coinciden con los scripts corregidos. Los cuatro estados y las cinco transiciones aparecen como inserciones en los SQL. En cambio, los registros de organización y tipos de incidente ya presentes en mi instancia no proceden de INSERT localizados en estos cuatro ficheros.

## 6. Decisión y trabajo pendiente

- Mantengo `SAPO_CORREGIDO_REVISION_ESTATICA.sql` como referencia del análisis actual.
- No vuelvo a ejecutar el esquema ni inserto otra organización o tipos de incidente: ya existen registros en mi base.
- No afirmo que la instancia local sea idéntica objeto por objeto; he contrastado recuentos generales y la información visible en pgAdmin.
- Debo localizar el origen de la organización y los siete tipos de incidente. Si no recupero ese origen, prepararé una carga reproducible, idempotente y revisada, sin IDs de identidad escritos a mano, y la probaré primero en una base de pruebas.
- Antes de generar una carga, revisaré columnas, restricciones, triggers y reglas de negocio aplicables.

## 7. Evidencia

La comprobación local está reflejada en las capturas de pgAdmin del 26/11/2026 y en el [registro de trabajo del Sprint 1](SPRINT_1_WORKLOG.md). La investigación del origen de los datos iniciales queda registrada en una tarea técnica relacionada con SAPO-003.
