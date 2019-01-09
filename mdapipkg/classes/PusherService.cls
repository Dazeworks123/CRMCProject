public with sharing class PusherService {
	public class PusherException extends Exception {
    }

    String app_id;
    String key;
    String secret;
    String cluster;

    public PusherService() {
        this.app_id =  '663217';
		this.key =  '0b9b27954005b8211a97';
		this.secret =  '5f1ac7e4948fae3e9710';
		this.cluster =  'ap1';
    }

    public void push(List<String> channelList, String event, Object messageObj) {
    	Map<String,Object> dataSend = new Map<String,Object>{
			'data'=>(JSON.serialize(messageObj)),
			'name'=>event,
			'channels'=>channelList
		};
		String message = JSON.serialize(dataSend);
		String authTimestamp = String.valueOf(Datetime.now().getTime() / 1000);
		String authVersion = '1.0';
		String bodyMd5 = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', 
		  Blob.valueOf(message)));
		String path = '/apps/'+app_id+'/events';

		String stringToSign = 'POST\n'+path+'\nauth_key='+key+
		    '&auth_timestamp='+authTimestamp+'&auth_version='+authVersion+
		    '&body_md5='+bodyMd5;

		String authSignature =
		    EncodingUtil.convertToHex(Crypto.generateMac('hmacSHA256',
		      Blob.valueOf(stringToSign), Blob.valueOf(secret)));

		String endpoint = 'https://api-'+cluster+'.pusher.com'+path+
		    '?auth_key='+key+
		    '&auth_timestamp='+authTimestamp+
		    '&auth_version='+authVersion+
		    '&body_md5='+bodyMd5+
		    '&auth_signature='+authSignature;

		HttpRequest req = new HttpRequest(); 

		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(endpoint);
		req.setBody(message);    
		Http http = new Http();
		HTTPResponse res = http.send(req);

		if (res.getStatusCode() != 200) {
		    throw new PusherException(res.getStatusCode() + ' ' + res.getStatus());
		}
    }
}