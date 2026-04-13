select id, protectedData,
JSONExtractString(protectedData, 'superHost') as superHost
from sg_users
where JSONExtractBool(protectedData, 'superHost') = true
