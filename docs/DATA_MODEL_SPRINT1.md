# Modelo de datos del circuito práctico — Sprint 1

## 1. Alcance

El circuito práctico de S.A.P.O. se centra en registrar y consultar incidencias ficticias relacionadas con personas. El modelo global está descrito en [Diseño de la base de datos](DATABASE_DESIGN.md).

El esquema SQL que sirve de base a este trabajo ya estaba preparado y ejecutado antes del inicio del Sprint 1. Durante esta iteración he revisado su aplicación al circuito práctico y he documentado las relaciones y dependencias necesarias.

## 2. Entidades principales

| Entidad | Función en el circuito |
|---|---|
| `PERSONA` | Almacenar los datos de las personas ficticias. |
| `INCIDENTE` | Registrar el hecho simulado, su fecha, descripción y estado. |
| `VINCULACION_PERSONA_INCIDENTE` | Asociar una o varias personas con una incidencia e identificar el tipo de vinculación. |
| `ORGANIZACION` | Proporcionar el contexto organizativo requerido por cada incidencia. |
| `TIPO_INCIDENTE` | Clasificar las incidencias. |
| `ESTADO_INCIDENTE` | Definir los estados disponibles. |
| `TRANSICION_ESTADO_INCIDENTE` | Limitar los cambios de estado permitidos. |
| `UBICACION` | Proporcionar una ubicación ficticia cuando sea necesario; su relación con incidente es opcional. |

## 3. Relaciones y dependencias

La relación entre PERSONA e INCIDENTE es de muchos a muchos y se implementa mediante `VINCULACION_PERSONA_INCIDENTE`.

Para registrar un incidente deben existir previamente una organización, un tipo de incidente y un estado válido. La ubicación es opcional. Para crear una vinculación deben existir tanto la persona como el incidente. Si se utiliza la consulta de antecedentes, el registro necesita una persona y un tipo de antecedente.

El tipo de vinculación entre persona e incidente se limita mediante la restricción definida en el esquema. Las transiciones de estado se controlan mediante el catálogo correspondiente y las reglas de negocio.

## 4. Datos existentes en mi entorno

El 26/11/2026 he comprobado en pgAdmin 4 los siguientes recuentos:

| Tabla | Registros |
|---|---:|
| ORGANIZACION | 1 |
| TIPO_INCIDENTE | 7 |
| ESTADO_INCIDENTE | 4 |
| TRANSICION_ESTADO_INCIDENTE | 5 |
| PERSONA | 0 |
| INCIDENTE | 0 |

Los siete tipos de incidente muestran fecha de creación 17/11/2026 alrededor de las 18:48:43, anterior al inicio del Sprint 1 (19/11/2026). Por tanto, forman parte de la preparación previa del entorno. El recuento confirma una organización, aunque todavía debo recuperar el origen exacto de su alta.

## 5. Datos iniciales para pruebas

Para completar el circuito se deberán proporcionar registros ficticios de personas antes de asociarlas con incidencias. Las incidencias necesitan organización, tipo y estado válidos.

He documentado el orden de preparación en [database/seeds/README.md](../database/seeds/README.md). No voy a duplicar los catálogos que ya existen en mi instancia. Primero recuperaré la carga original o prepararé una alternativa reproducible e idempotente en un entorno de prueba.

## 6. Verificación del esquema

He comprobado en pgAdmin que mi instancia local contiene 24 tablas y 31 claves foráneas, coincidiendo en esos recuentos con el diseño SQL de referencia. Esta comprobación valida los recuentos, pero no equivale a verificar individualmente todas las columnas, índices, restricciones, funciones y triggers.

La justificación formal de 1FN, 2FN y 3FN para el modelo global queda identificada como trabajo de diseño pendiente de completar antes de dar por acreditado ese requisito de la asignatura.

## 7. Evidencias

- [Diseño de la base de datos de S.A.P.O.](DATABASE_DESIGN.md)
- [Estrategia de datos iniciales ficticios](../database/seeds/README.md)
- [Registro de trabajo del Sprint 1](SPRINT_1_WORKLOG.md)
- [Tarea técnica para recuperar el origen de los datos](https://github.com/Zanguango/SAPO/issues/51)
