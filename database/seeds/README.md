# Estrategia de datos iniciales ficticios

## 1. Objetivo

Definir cómo proporcionar los registros de entidades vinculadas que deben existir previamente para poder utilizar el circuito práctico de personas e incidencias. Este documento diseña el mecanismo; no implementa ni ejecuta todavía los scripts de carga.

## 2. Criterios

- Utilizar exclusivamente registros ficticios.
- Separar los scripts de esquema de los scripts de datos iniciales.
- Respetar el orden de dependencias y las claves foráneas.
- Evitar IDs de identidad escritos a mano: resolver los registros mediante claves de negocio o códigos únicos.
- Diseñar las cargas para que puedan repetirse sin duplicar registros (idempotencia).
- No incluir contraseñas en texto plano, secretos ni credenciales reales.
- Verificar primero que el esquema local coincide con la versión SQL analizada.

## 3. Orden de preparación propuesto

| Orden | Tabla o conjunto | Motivo / dependencia |
|---:|---|---|
| 1 | `PERFIL` | Catálogo de perfiles. El script de esquema ya inserta ADMINISTRADOR, SUPERVISOR y AGENTE. |
| 2 | `ESTADO_INCIDENTE` | Catálogo de estados. El script de esquema ya inserta REGISTRADO, EN_GESTION, PENDIENTE y RESUELTO. |
| 3 | `TRANSICION_ESTADO_INCIDENTE` | Depende de los estados. El script de esquema ya inserta cinco transiciones. |
| 4 | `ORGANIZACION` | Requerida por `INCIDENTE.id_organizacion` y por unidades/historial organizativo. En mi instancia local ya existe 1 registro; los dos ficheros SQL revisados no muestran su inserción, así que debo identificar y versionar el origen antes de recrear la base. |
| 5 | `TIPO_INCIDENTE` | Requerido por `INCIDENTE.id_tipo_incidente`. En mi instancia local ya existen 7 registros; los dos ficheros SQL revisados no muestran su inserción, así que debo identificar y versionar el origen antes de recrear la base. |
| 6 | `UBICACION` | Opcional para INCIDENTE; solo preparar filas si se va a utilizar ubicación en las pruebas. |
| 7 | `PERSONA` | Entidad principal que se asociará a incidencias; no tiene FK entrante para su alta básica. |
| 8 | `TIPO_ANTECEDENTE` | Solo necesario si se activa la consulta/registro de antecedentes condicionado. |
| 9 | `USUARIO` | Requerido para autenticación de prueba; debe recibir password_hash generado por mecanismo seguro, nunca contraseña plana. |
| 10 | `HISTORIAL_PERFIL_USUARIO` | Requiere usuario y perfil existentes; sirve para asignar el perfil al usuario de prueba. |
| 11 | `HISTORIAL_PERTENENCIA_ORGANIZATIVA` | Requiere usuario y organización; solo si el circuito aplica el contexto organizativo del usuario. |
| 12 | `UNIDAD_ORGANIZATIVA` y `HISTORIAL_UNIDAD_USUARIO` | Solo si se necesita asignar usuarios a unidades o usar asignaciones dirigidas a una unidad. |
| 13 | `INCIDENTE` | Requiere organización, tipo de incidente y estado; ubicación es opcional. |
| 14 | `VINCULACION_PERSONA_INCIDENTE` | Requiere una persona y una incidencia existentes. |
| 15 | `ANTECEDENTE` | Solo si se usa el módulo condicionado; requiere persona y tipo de antecedente. |
| 16 | `ASIGNACION_INCIDENTE` | Módulo posterior; requiere incidencia y exactamente uno de usuario o unidad. |

Para el circuito mínimo de registro y consulta de incidencias, el conjunto esencial de datos relacionados es: una ORGANIZACION, al menos un TIPO_INCIDENTE y los ESTADO_INCIDENTE/transiciones del catálogo; además, deben existir las personas antes de crear sus vinculaciones con incidencias. La UBICACION es opcional.

## 4. Comportamiento de las cargas

Cuando se implementen los scripts:
1. Utilizar transacciones para mantener la carga coherente.
2. Resolver los IDs de catálogos y entidades mediante códigos o claves naturales estables.
3. Aprovechar restricciones únicas e índices normalizados para evitar duplicados.
4. Incorporar únicamente valores ficticios etiquetados como datos de demostración.
5. Si un registro ya existe, reutilizarlo o actualizar solo los campos previstos; no crear otra fila por cada ejecución.
6. Registrar en la documentación el orden de ejecución y los requisitos previos.

## 5. Decisión de autenticación de prueba

El usuario de prueba se creará cuando exista el backend o un procedimiento controlado para generar hash. El script SQL no debe contener una contraseña reutilizable ni un hash copiado sin una política de generación conocida. La asignación del perfil se realizará mediante `HISTORIAL_PERFIL_USUARIO` tras insertar el usuario.

## 6. Estado comprobado en mi entorno — 26/11/2026

He comprobado en pgAdmin que sapo_db contiene 1 ORGANIZACION, 7 TIPO_INCIDENTE, 4 ESTADO_INCIDENTE y 5 TRANSICION_ESTADO_INCIDENTE; todavía tiene 0 PERSONA y 0 INCIDENTE. Los catálogos de estados y transiciones tienen registros iniciales del SQL revisado. La organización y los tipos de incidente que ya existen en mi base local no aparecen insertados en los dos ficheros SQL analizados. Debo localizar el script o procedimiento previo que los creó, o preparar una carga versionada equivalente antes de recrear la base.

## 7. Pendiente antes de implementar

- Confirmar en pgAdmin que el esquema de `sapo_db` coincide con `SAPO_CORREGIDO_REVISION_ESTATICA.sql`.
- Confirmar con el flujo funcional los datos mínimos de demostración que se necesitan.
- Diseñar los INSERT/UPSERT específicos y probar que pueden ejecutarse más de una vez sin duplicados.
- Mantener la creación de datos de demostración separada de los registros creados por las operaciones funcionales del usuario.
