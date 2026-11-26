# Datos iniciales ficticios de S.A.P.O.

## 1. Objetivo

Dejo documentado cómo preparar los registros de entidades vinculadas que deben existir antes de ejecutar el circuito de personas e incidencias. Mantengo separados el esquema SQL y los datos iniciales para poder crear y probar la base de forma controlada.

## 2. Reglas de preparación

- Utilizar exclusivamente registros ficticios.
- Respetar las claves foráneas y el orden de dependencias.
- No escribir manualmente IDs de identidad; resolver registros mediante códigos o claves de negocio.
- Preparar cargas idempotentes para que puedan ejecutarse más de una vez sin duplicar registros.
- Mantener separados los datos de catálogo y los registros creados mediante operaciones de la aplicación.
- No incluir contraseñas en texto plano ni credenciales reales.
- Probar cualquier nueva carga en una base aislada antes de utilizarla en mi instancia local.

## 3. Orden de preparación previsto

| Orden | Tabla o conjunto | Dependencia |
|---:|---|---|
| 1 | `PERFIL` | Catálogo de perfiles de usuario. |
| 2 | `ESTADO_INCIDENTE` | Catálogo de estados válidos. |
| 3 | `TRANSICION_ESTADO_INCIDENTE` | Requiere los estados de origen y destino. |
| 4 | `ORGANIZACION` | Requerida para registrar incidencias y para determinadas relaciones organizativas. |
| 5 | `TIPO_INCIDENTE` | Requerido para clasificar una incidencia. |
| 6 | `UBICACION` | Opcional; solo se prepara si se utiliza en los datos de prueba. |
| 7 | `PERSONA` | Debe existir antes de asociarse con una incidencia. |
| 8 | `TIPO_ANTECEDENTE` | Solo si se habilita la consulta de antecedentes. |
| 9 | `USUARIO` | Necesario para probar autenticación; requiere un hash seguro de contraseña. |
| 10 | `HISTORIAL_PERFIL_USUARIO` | Requiere un usuario y un perfil ya existentes. |
| 11 | `INCIDENTE` | Requiere organización, tipo de incidente y estado; ubicación opcional. |
| 12 | `VINCULACION_PERSONA_INCIDENTE` | Requiere una persona y una incidencia ya existentes. |
| 13 | `ANTECEDENTE` | Solo si se activa el módulo condicionado; requiere persona y tipo de antecedente. |

Este orden es una guía de dependencias, no una indicación para volver a insertar registros que ya existen.

## 4. Estado de los datos en mi base local — 26/11/2026

He comprobado en pgAdmin que mi base `sapo_db` contiene:

| Tabla | Registros |
|---|---:|
| ORGANIZACION | 1 |
| TIPO_INCIDENTE | 7 |
| ESTADO_INCIDENTE | 4 |
| TRANSICION_ESTADO_INCIDENTE | 5 |
| PERSONA | 0 |
| INCIDENTE | 0 |

Los siete tipos de incidente visibles en pgAdmin son:

1. ROBO
2. HURTO
3. DANOS
4. AMENAZAS
5. AGRESION
6. DESAPARICION
7. OTROS

La columna `fecha_creacion` de estos siete registros muestra el 17/11/2026 alrededor de las 18:48:43, antes del inicio del Sprint 1. La organización ya existe según el recuento, aunque debo recuperar el detalle y el origen de su alta.

No modificaré ni duplicaré estos registros mientras investigo cómo se crearon.

## 5. Datos iniciales del esquema

El esquema de referencia contempla los registros iniciales de perfiles, estados y transiciones. La organización y los siete tipos de incidente que aparecen en mi instancia local deben conservarse o poder reproducirse mediante una carga específica. Para ello revisaré el Query History de pgAdmin y los scripts de preparación anteriores.

## 6. Carga reproducible

Cuando haya recuperado el origen de los registros, versionaré el mecanismo correspondiente dentro de este directorio. Si no puedo recuperar el script original, prepararé una carga equivalente tras verificar columnas, restricciones y reglas de negocio.

Antes de utilizarla:
1. la ejecutaré en una base de pruebas;
2. comprobaré que no duplica registros si se repite;
3. comprobaré que respeta las claves foráneas y los valores únicos;
4. compararé los recuentos antes y después;
5. documentaré el resultado y enlazaré el commit a la tarea técnica.

## 7. Tarea de seguimiento

La investigación queda registrada en la [tarea técnica #51](https://github.com/Zanguango/SAPO/issues/51), relacionada con SAPO-003. No volveré a insertar los siete tipos ni la organización en mi base local como parte de esta investigación.
