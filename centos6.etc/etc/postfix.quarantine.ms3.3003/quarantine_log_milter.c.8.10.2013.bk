/*
**  Written by Bappasaheb Nirmal@qlc.in, Dated 12th Nov,2008
**  gcc -D_REENTRANT -o quarantine_log_milter.ms3 quarantine_log_milter.c -lmilter -lresolv  -lnsl -lpthread -I/usr/include/mysql -L/usr/lib/mysql -lmysqlclient -lz -lm -L/usr/lib
**  OR
**  gcc -D_REENTRANT -o quarantine_log_milter quarantine_log_milter.c -lmilter -lresolv  -lnsl -lpthread `mysql_config --include` `mysql_config --libs`

** gcc -D_REENTRANT -o quarantine_log_milter quarantine_log_milter.c -lmilter -lresolv  -lnsl -lpthread -I/usr/include/mysql -L/usr/lib/mysql -lmysqlclient -lz -lm -L/usr/lib -lmysqlclient_r

**  This milter logs email headers to the mysql database.
*/

#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <unistd.h>
#include <stddef.h>
#include <fcntl.h>
#include <pthread.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <signal.h>



#include "libmilter/mfapi.h"
#include "libmilter/mfdef.h"

#include <mysql.h>
#include <errno.h>

#ifndef true
# define false	0
# define true	1
#endif /* ! true */


#define SERVER                  "localhost"
#define USER                    "mailserve"
#define PASSWORD                "mail1234"
#define DATABASE                "Quarantine_v03"

#define SERVER_MAILSERVE                  "localhost"
#define USER_MAILSERVE                    "mailserve"
#define PASSWORD_MAILSERVE                "mail1234"
#define DATABASE_MAILSERVE                "mailserve_v03"



MYSQL	*MYSQLconn,*MYSQLconn_mailserve;
MYSQL_RES *res;
MYSQL_ROW row;


static pthread_mutex_t popen_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
int count = 1;

static pthread_mutex_t popen_mutex2 = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t cond2 = PTHREAD_COND_INITIALIZER;
int count2 = 1;



struct mlfiPriv
{
	char	*message_id;
	char 	*message_from;
	char 	*message_to;
	char	*message_subject;	
	char 	*user;
	char	*delivered_to;
	char	*client_id;
};

#define MLFIPRIV	((struct mlfiPriv *) smfi_getpriv(ctx))

static unsigned long mta_caps = 0;


char  * addslashes(MYSQL *connection , char * to ,const char *from)
{
	to = (char *)malloc (strlen(from) * 2 + 1);
	if (to == NULL)
	{
		return NULL;
	}
	mysql_real_escape_string (connection , to ,from , strlen(from));
	return to;
}


sfsistat
mlfi_cleanup(ctx, ok)
	SMFICTX *ctx;
	bool ok;
{
	sfsistat rstat = SMFIS_CONTINUE;
	struct mlfiPriv *priv = MLFIPRIV;
	char *query;
	int len = 0;
	char *user;
	char *clientcode;
	int i = 0;
	int rv;
	

	if (priv == NULL)
		return rstat;

	if(priv->message_id != NULL) {
		len = len + strlen(priv->message_id);
	}
	else {
		len = len + 6;
	}

        if(priv->message_subject != NULL) {
                len = len + strlen(priv->message_subject);
        }
	else {
		len = len + 6;
	}
        if(priv->message_from != NULL) {
                len = len + strlen(priv->message_from);
        }
	else {
		len = len + 6;
	}

        if(priv->message_to != NULL) {
                len = len + strlen(priv->message_to);
        }
	else {
		len = len + 6;
	}

        if(priv->delivered_to != NULL) {
                len = len + strlen(priv->delivered_to);
        }
        else {
                len = len + 6;
        }


        if(priv->user != NULL) {
                len = len + strlen(priv->user);
        }
        else {
                len = len + 6;
        }

        if(priv->client_id != NULL) {
                len = len + strlen(priv->client_id);
        }
        else {
                len = len + 6;
        }



	// Calculate the size of query stmt
	query = (char *)malloc(len+154);
	snprintf (query,len+154, "insert into CommtochQuarantine(MessageID,MessageSubject,MessageFrom,MessageTo,DspamUser,ClientCode,Date,DeliveredTo) values('%s','%s','%s','%s','%s','%s',NOW(''),'%s')",priv->message_id,priv->message_subject,priv->message_from,priv->message_to,priv->user,priv->client_id,priv->delivered_to);
	
	free(clientcode);
	free(user);
/*
	printf("\n==> %d=>%d\r\n",len+154,strlen(query));

	snprintf (hbuf, sizeof (hbuf), "insert into CommtochQuarantine(MessageID,MessageFrom,MessageTo,MessageSubject,Date) values('%s','%s','%s','%s',NOW(''))",priv->message_id,priv->message_subject,priv->message_from,priv->message_to);
	len=strlen(hbuf);
        fprintf(priv->mlfi_fp, "==> %s=>%d\r\n",hbuf,len);
*/

	if (ok) {

		//making serial access to the mysql connect

		rv = pthread_mutex_lock(&popen_mutex);
		if(rv) {
			abort();
		}
		while (count == 0)
			pthread_cond_wait(&cond, &popen_mutex);
		count = count - 1;
		pthread_mutex_unlock(&popen_mutex);
			

		if (mysql_query(MYSQLconn,query)) {
			rstat = SMFIS_TEMPFAIL;
			fputs(mysql_error(MYSQLconn), stderr);

		}


		pthread_mutex_lock(&popen_mutex);
		if (count == 0)
			pthread_cond_signal(&cond);			
		count = count + 1;
		rv = pthread_mutex_unlock(&popen_mutex);
		if(rv) {
			abort();
		}




		smfi_addheader(ctx, "X-QLC-ACTION", "Quarantined");
	}
	free(query);

	/* release private memory */
	free(priv->message_id);
	free(priv->message_subject);
	free(priv->message_from);
	free(priv->message_to);
	free(priv->delivered_to);
	free(priv->client_id);
	free(priv->user);

	free(priv);
	smfi_setpriv(ctx, NULL);

	/* return status */
	return rstat;
}

sfsistat mlfi_envrcpt(SMFICTX *ctx, char **argv)
{
	char *rcptaddr;
	char *user,*query;
	int len,rv;
	//char query[2000];

	rcptaddr = smfi_getsymval(ctx, "{rcpt_addr}");
	MLFIPRIV->delivered_to = strdup(rcptaddr);
	len = strlen(rcptaddr);
	query = (char *)malloc(6 * len + 1296);

	sprintf (query,"(select client_users.email_address as login,client_users.client_id from client_users,pop_accounts where client_users.id =   pop_accounts.client_user_id and client_domain_id = 0 and email_address= SUBSTRING_INDEX('%s','@',1) and 'qlc.co.in' = SUBSTRING_INDEX('%s','@',-1)) union (select concat(client_users.email_address,'@',client_domains.name) as login,client_users.client_id from client_users,pop_accounts,client_domains where client_users.id =   pop_accounts.client_user_id and client_users.client_domain_id = client_domains.id and email_address = SUBSTRING_INDEX('%s','@',1) and client_domains.name = SUBSTRING_INDEX('%s','@',-1))  union (SELECT IF(client_users.client_domain_id = 0, client_users.email_address, CONCAT(client_users.email_address,'@',cu_client_domains.name)) AS login,client_users.client_id FROM pop_email_aliases LEFT JOIN client_domains ON (pop_email_aliases.client_domain_id = client_domains.id) LEFT JOIN pop_accounts ON (pop_email_aliases.pop_account_id = pop_accounts.id) LEFT JOIN client_users ON (pop_accounts.client_user_id = client_users.id) LEFT JOIN client_domains AS cu_client_domains ON (client_users.client_domain_id = cu_client_domains.id) WHERE pop_email_aliases.email_address = SUBSTRING_INDEX('%s','@',1) and client_domains.name = SUBSTRING_INDEX('%s','@',-1)) limit 1",rcptaddr,rcptaddr,rcptaddr,rcptaddr,rcptaddr,rcptaddr);



//printf("\n %d:%d::%d",strlen(query),6 * len,strlen(query) - 6 * len);



	/* Needs to serialise access to following area */

	rv = pthread_mutex_lock(&popen_mutex2);
	if(rv) {
		abort();
	}
	while (count2 == 0)
		pthread_cond_wait(&cond2, &popen_mutex2);
	count2 = count2 - 1;
	pthread_mutex_unlock(&popen_mutex2);




	if (mysql_query(MYSQLconn_mailserve,query)) {
		fputs(mysql_error(MYSQLconn_mailserve), stderr);
		return SMFIS_TEMPFAIL;
	}
	free(query);

	if (!(res = mysql_store_result(MYSQLconn_mailserve))) {
		fputs(mysql_error(MYSQLconn_mailserve), stderr);
	}

	free(MLFIPRIV->user);
	free(MLFIPRIV->client_id);

	if((row = mysql_fetch_row(res))) {
		MLFIPRIV->user = addslashes(MYSQLconn_mailserve,MLFIPRIV->user,row[0]);
		MLFIPRIV->client_id = addslashes(MYSQLconn_mailserve,MLFIPRIV->client_id,row[1]);
	}
	else {
		MLFIPRIV->user = addslashes(MYSQLconn_mailserve,MLFIPRIV->user,rcptaddr);
		MLFIPRIV->client_id = addslashes(MYSQLconn_mailserve,MLFIPRIV->client_id,rcptaddr);
	}

	if (res != NULL)
		mysql_free_result(res);

	pthread_mutex_lock(&popen_mutex2);
        if (count2 == 0)
        	pthread_cond_signal(&cond2);
        count2 = count2 + 1;
        rv = pthread_mutex_unlock(&popen_mutex2);
        if(rv) {
        	abort();
        }

	/* end of serial access */


	if (MLFIPRIV->user == NULL)
	{
		return SMFIS_TEMPFAIL;
	}

        /* continue processing */
        return SMFIS_CONTINUE;


}

sfsistat
mlfi_envfrom(ctx, envfrom)
	SMFICTX *ctx;
	char **envfrom;
{
	struct mlfiPriv *priv;

	/* allocate some private memory */
	priv = malloc(sizeof *priv);
	if (priv == NULL)
	{
		/* can't accept this message right now */
		return SMFIS_TEMPFAIL;
	}
	memset(priv, '\0', sizeof *priv);

	priv->message_id = NULL;
	priv->message_subject = NULL;
	priv->message_from = NULL;
	priv->message_to = NULL;
	priv->user = NULL;
	priv->client_id = NULL;

	/* save the private data */
	smfi_setpriv(ctx, priv);

	/* continue processing */
	return SMFIS_CONTINUE;
}

sfsistat
mlfi_header(ctx, headerf, headerv)
	SMFICTX *ctx;
	char *headerf;
	char *headerv;
{

	if(!strcasecmp("Message-ID",headerf)) {
		MLFIPRIV->message_id = addslashes(MYSQLconn,MLFIPRIV->message_id,headerv);
        	if (MLFIPRIV->message_id == NULL)
	        {
                	return SMFIS_TEMPFAIL;
	        }
	}
	else if(!strcasecmp("Subject",headerf)) {
		MLFIPRIV->message_subject = addslashes(MYSQLconn,MLFIPRIV->message_subject,headerv);
                if (MLFIPRIV->message_subject == NULL)
                {
                        return SMFIS_TEMPFAIL;
                }
	}
	else if(!strcasecmp("From",headerf)) {
		MLFIPRIV->message_from = addslashes(MYSQLconn,MLFIPRIV->message_from,headerv);
                if (MLFIPRIV->message_from == NULL)
                {
                        return SMFIS_TEMPFAIL;
                }
	}
	else if(!strcasecmp("To",headerf)) {
		MLFIPRIV->message_to = addslashes(MYSQLconn,MLFIPRIV->message_to,headerv);
                if (MLFIPRIV->message_to == NULL)
                {
                        return SMFIS_TEMPFAIL;
                }
	}

	return SMFIS_CONTINUE;

	/* continue processing */
	//return ((mta_caps & SMFIP_NR_HDR) != 0)
	//	? SMFIS_NOREPLY : SMFIS_CONTINUE;
}

sfsistat
mlfi_eom(ctx)
	SMFICTX *ctx;
{
	return mlfi_cleanup(ctx, true);
}

sfsistat
mlfi_close(ctx)
	SMFICTX *ctx;
{
	return SMFIS_ACCEPT;
}

sfsistat
mlfi_abort(ctx)
	SMFICTX *ctx;
{
	return mlfi_cleanup(ctx, false);
}


struct smfiDesc smfilter =
{
	"SampleFilter",	/* filter name */
	SMFI_VERSION,	/* version code -- do not change */
	SMFIF_ADDHDRS,	/* flags */
	NULL,		/* connection info filter */
	NULL,		/* SMTP HELO command filter */
	mlfi_envfrom,	/* envelope sender filter */
	mlfi_envrcpt,	/* envelope recipient filter */
	mlfi_header,	/* header filter */
	NULL,	/* end of header */
	NULL,	/* body block filter */
	mlfi_eom,	/* end of message */
	mlfi_abort,	/* message aborted */
	mlfi_close	/* connection cleanup */
};

int
main(argc, argv)
	int argc;
	char *argv[];
{
	bool setconn;
	int c;

        MYSQLconn = mysql_init(NULL);
        if (MYSQLconn == NULL)
        {
                fputs(mysql_error(MYSQLconn), stderr);
        }

        if (!mysql_real_connect(MYSQLconn, SERVER,USER, PASSWORD, DATABASE, 0, NULL, 0)) {
                fputs(mysql_error(MYSQLconn), stderr);
        }

        MYSQLconn_mailserve = mysql_init(NULL);
        if (MYSQLconn_mailserve == NULL)
        {
                fputs(mysql_error(MYSQLconn_mailserve), stderr);
        }

        if (!mysql_real_connect(MYSQLconn_mailserve, SERVER_MAILSERVE,USER_MAILSERVE, PASSWORD_MAILSERVE, DATABASE_MAILSERVE, 0, NULL, 0)) {
                fputs(mysql_error(MYSQLconn_mailserve), stderr);
        }



	setconn = false;

	/* Process command line options */
	while ((c = getopt(argc, argv, "p:")) != -1)
	{
		switch (c)
		{
		  case 'p':
			if (optarg == NULL || *optarg == '\0')
			{
				(void) fprintf(stderr, "Illegal conn: %s\n",
					       optarg);
				exit(EX_USAGE);
			}
			(void) smfi_setconn(optarg);
			setconn = true;
			break;

		}
	}
	if (!setconn)
	{
		fprintf(stderr, "%s: Missing required -p argument\n", argv[0]);
		exit(EX_USAGE);
	}
	if (smfi_register(smfilter) == MI_FAILURE)
	{
		fprintf(stderr, "smfi_register failed\n");
		exit(EX_UNAVAILABLE);
	}
	umask(0111);
	return smfi_main();
}

