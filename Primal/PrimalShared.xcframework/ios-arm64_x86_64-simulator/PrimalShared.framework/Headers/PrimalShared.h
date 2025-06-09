#import <Foundation/NSArray.h>
#import <Foundation/NSDictionary.h>
#import <Foundation/NSError.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSSet.h>
#import <Foundation/NSString.h>
#import <Foundation/NSValue.h>

@class PrimalShared__SkieTypeExportsKt, PrimalShared__SkieSuspendWrappersKt, PrimalSharedZapTargetReplaceableEvent, PrimalSharedZapTargetProfile, PrimalSharedZapTargetEvent, PrimalSharedZapTarget, PrimalSharedZapResultSuccess, PrimalSharedZapResultFailure, PrimalSharedZapResult, PrimalSharedZapRequestData, PrimalSharedZapErrorUnknown, PrimalSharedZapErrorInvalidZap, PrimalSharedZapErrorFailedToSignEvent, PrimalSharedZapErrorFailedToPublishEvent, PrimalSharedZapErrorFailedToFetchZapPayRequest, PrimalSharedZapErrorFailedToFetchZapInvoice, PrimalSharedZapError, PrimalSharedValidationUtilsKt, PrimalSharedUserProfileSearchItem, PrimalSharedUploadResultSuccess, PrimalSharedUploadResultFailed, PrimalSharedUploadResult, PrimalSharedUploadRequirementException, PrimalSharedUShort, PrimalSharedULong, PrimalSharedUInt, PrimalSharedUByte, PrimalSharedTlvRecordCompanion, PrimalSharedTlvRecord, PrimalSharedTagsKt, PrimalSharedTagBookmarkCompanion, PrimalSharedTagBookmark, PrimalSharedStringUtilsKt_, PrimalSharedStringUtilsKt, PrimalSharedSkie_SuspendResultSuccess, PrimalSharedSkie_SuspendResultError, PrimalSharedSkie_SuspendResultCanceled, PrimalSharedSkie_SuspendResult, PrimalSharedSkie_SuspendHandler, PrimalSharedSkie_CancellationHandler, PrimalSharedSkieKotlinStateFlow<T>, PrimalSharedSkieKotlinSharedFlow<T>, PrimalSharedSkieKotlinOptionalStateFlow<T>, PrimalSharedSkieKotlinOptionalSharedFlow<T>, PrimalSharedSkieKotlinOptionalMutableStateFlow<T>, PrimalSharedSkieKotlinOptionalMutableSharedFlow<T>, PrimalSharedSkieKotlinOptionalFlow<T>, PrimalSharedSkieKotlinMutableStateFlow<T>, PrimalSharedSkieKotlinMutableSharedFlow<T>, PrimalSharedSkieKotlinFlow<T>, PrimalSharedSkieColdFlowIterator<E>, PrimalSharedSigningRejectedException, PrimalSharedSigningKeyNotFoundException, PrimalSharedSignatureException, PrimalSharedSignResultSigned, PrimalSharedSignResultRejected, PrimalSharedSignResult, PrimalSharedShort, PrimalSharedRetryKt, PrimalSharedReportType, PrimalSharedReferencedZapCompanion, PrimalSharedReferencedZap, PrimalSharedReferencedUserCompanion, PrimalSharedReferencedUser, PrimalSharedReferencedNoteCompanion, PrimalSharedReferencedNote, PrimalSharedReferencedHighlightCompanion, PrimalSharedReferencedHighlight, PrimalSharedReferencedArticleCompanion, PrimalSharedReferencedArticle, PrimalSharedReactionType, PrimalSharedPublicBookmarksNotFoundException, PrimalSharedPublicBookmark, PrimalSharedProfileStats, PrimalSharedProfileData, PrimalSharedPrimalTimeframe, PrimalSharedPrimalSocketSubscriptionCompanion, PrimalSharedPrimalSocketSubscription<T>, PrimalSharedPrimalServerType, PrimalSharedPrimalServerConnectionStatus, PrimalSharedPrimalScope, PrimalSharedPrimalQueryResult, PrimalSharedPrimalPublishResult, PrimalSharedPrimalPremiumInfoCompanion, PrimalSharedPrimalPremiumInfo, PrimalSharedPrimalLegendProfileCompanion, PrimalSharedPrimalLegendProfile, PrimalSharedPrimalInitializer, PrimalSharedPrimalFeed, PrimalSharedPrimalEventCompanion, PrimalSharedPrimalEvent, PrimalSharedPrimalCacheFilter, PrimalSharedPrimalApiClientFactory, PrimalSharedPremiumExtKt, PrimalSharedPayerDataRequirementCompanion, PrimalSharedPayerDataRequirement, PrimalSharedPayerDataCompanion, PrimalSharedPayerData, PrimalSharedPayKeysendResponsePayloadCompanion, PrimalSharedPayKeysendResponsePayload, PrimalSharedPayKeysendParamsCompanion, PrimalSharedPayKeysendParams, PrimalSharedPayInvoiceResponsePayloadCompanion, PrimalSharedPayInvoiceResponsePayload, PrimalSharedPayInvoiceParamsCompanion, PrimalSharedPayInvoiceParams, PrimalSharedPaging_commonPagingDataCompanion, PrimalSharedPaging_commonPagingData<T>, PrimalSharedPaging_commonLoadType, PrimalSharedPaging_commonLoadStates, PrimalSharedPaging_commonLoadStateNotLoading, PrimalSharedPaging_commonLoadStateLoading, PrimalSharedPaging_commonLoadStateError, PrimalSharedPaging_commonLoadState, PrimalSharedOkioTimeoutCompanion, PrimalSharedOkioTimeout, PrimalSharedOkioIOException, PrimalSharedOkioByteStringCompanion, PrimalSharedOkioByteString, PrimalSharedOkioBufferUnsafeCursor, PrimalSharedOkioBuffer, PrimalSharedOGLeaderboardEntry, PrimalSharedNwcWalletRequestCompanion, PrimalSharedNwcWalletRequest<T>, PrimalSharedNwcResultSuccess<T>, PrimalSharedNwcResultFailure<T>, PrimalSharedNwcResult<T>, PrimalSharedNwcResponseContentCompanion, PrimalSharedNwcResponseContent<T>, PrimalSharedNwcMethodPaymentSent, PrimalSharedNwcMethodPaymentReceived, PrimalSharedNwcMethodPayKeysend, PrimalSharedNwcMethodPayInvoice, PrimalSharedNwcMethodMultiPayKeysend, PrimalSharedNwcMethodMultiPayInvoice, PrimalSharedNwcMethodMakeInvoice, PrimalSharedNwcMethodLookupInvoice, PrimalSharedNwcMethodListTransactions, PrimalSharedNwcMethodGetInfo, PrimalSharedNwcMethodGetBalance, PrimalSharedNwcMethod, PrimalSharedNwcErrorCompanion, PrimalSharedNwcError, PrimalSharedNwcClientFactory, PrimalSharedNumber, PrimalSharedNprofile, PrimalSharedNotificationTypeCompanion, PrimalSharedNotificationType, PrimalSharedNotificationSettingsTypeTabNotificationsZaps, PrimalSharedNotificationSettingsTypeTabNotificationsReposts, PrimalSharedNotificationSettingsTypeTabNotificationsReplies, PrimalSharedNotificationSettingsTypeTabNotificationsReactions, PrimalSharedNotificationSettingsTypeTabNotificationsNewFollows, PrimalSharedNotificationSettingsTypeTabNotificationsMentions, PrimalSharedNotificationSettingsTypeTabNotifications, PrimalSharedNotificationSettingsTypePushNotificationsZaps, PrimalSharedNotificationSettingsTypePushNotificationsWalletTransactions, PrimalSharedNotificationSettingsTypePushNotificationsReposts, PrimalSharedNotificationSettingsTypePushNotificationsReplies, PrimalSharedNotificationSettingsTypePushNotificationsReactions, PrimalSharedNotificationSettingsTypePushNotificationsNewFollows, PrimalSharedNotificationSettingsTypePushNotificationsMentions, PrimalSharedNotificationSettingsTypePushNotificationsDirectMessages, PrimalSharedNotificationSettingsTypePushNotificationsCompanion, PrimalSharedNotificationSettingsTypePushNotifications, PrimalSharedNotificationSettingsTypePreferencesReactionsFromFollows, PrimalSharedNotificationSettingsTypePreferencesHellThread, PrimalSharedNotificationSettingsTypePreferencesDMsFromFollows, PrimalSharedNotificationSettingsTypePreferencesCompanion, PrimalSharedNotificationSettingsTypePreferences, PrimalSharedNotificationSettingsType, PrimalSharedNotificationSettingsSection, PrimalSharedNotification, PrimalSharedNostrWalletKeypairCompanion, PrimalSharedNostrWalletKeypair, PrimalSharedNostrWalletConnectCompanion, PrimalSharedNostrWalletConnect, PrimalSharedNostrUriUtilsKt, PrimalSharedNostrUnsignedEventCompanion, PrimalSharedNostrUnsignedEvent, PrimalSharedNostrSocketClientFactory, PrimalSharedNostrPublishException, PrimalSharedNostrNoticeException, PrimalSharedNostrKeyPair, PrimalSharedNostrIncomingMessageParserKt, PrimalSharedNostrIncomingMessageOkMessage, PrimalSharedNostrIncomingMessageNoticeMessage, PrimalSharedNostrIncomingMessageExtKt, PrimalSharedNostrIncomingMessageEventsMessage, PrimalSharedNostrIncomingMessageEventMessage, PrimalSharedNostrIncomingMessageEoseMessage, PrimalSharedNostrIncomingMessageCountMessage, PrimalSharedNostrIncomingMessageAuthMessage, PrimalSharedNostrIncomingMessage, PrimalSharedNostrExtensions, PrimalSharedNostrException, PrimalSharedNostrEventUserStats, PrimalSharedNostrEventStats, PrimalSharedNostrEventKindRange, PrimalSharedNostrEventKindCompanion, PrimalSharedNostrEventKind, PrimalSharedNostrEventExtKt, PrimalSharedNostrEventCompanion, PrimalSharedNostrEventAction, PrimalSharedNostrEvent, PrimalSharedNip94Metadata, PrimalSharedNip19TLVType, PrimalSharedNip19TLV, PrimalSharedNevent, PrimalSharedNetworkException, PrimalSharedNaddrKt, PrimalSharedNaddr, PrimalSharedMutableSet<ObjectType>, PrimalSharedMutableDictionary<KeyType, ObjectType>, PrimalSharedMissingRelaysException, PrimalSharedMimeType, PrimalSharedMimeSubtype, PrimalSharedMime, PrimalSharedMessageEncryptException, PrimalSharedMakeInvoiceResponsePayloadCompanion, PrimalSharedMakeInvoiceResponsePayload, PrimalSharedMakeInvoiceParamsCompanion, PrimalSharedMakeInvoiceParams, PrimalSharedLookupInvoiceResponsePayloadCompanion, PrimalSharedLookupInvoiceResponsePayload, PrimalSharedLookupInvoiceParamsCompanion, PrimalSharedLookupInvoiceParams, PrimalSharedLong, PrimalSharedLnInvoiceUtilsAddressFormatException, PrimalSharedLnInvoiceUtils, PrimalSharedListTransactionsResponsePayloadCompanion, PrimalSharedListTransactionsResponsePayload, PrimalSharedListTransactionsParamsCompanion, PrimalSharedListTransactionsParams, PrimalSharedLightningPayResponseCompanion, PrimalSharedLightningPayResponse, PrimalSharedLightningPayRequestCompanion, PrimalSharedLightningPayRequest, PrimalSharedLightningExtKt, PrimalSharedLightningAddressChecker, PrimalSharedLeaderboardLegendEntry, PrimalSharedKtor_utilsWeekDayCompanion, PrimalSharedKtor_utilsWeekDay, PrimalSharedKtor_utilsTypeInfo, PrimalSharedKtor_utilsStringValuesBuilderImpl, PrimalSharedKtor_utilsPipelinePhase, PrimalSharedKtor_utilsPipeline<TSubject, TContext>, PrimalSharedKtor_utilsMonthCompanion, PrimalSharedKtor_utilsMonth, PrimalSharedKtor_utilsGMTDateCompanion, PrimalSharedKtor_utilsGMTDate, PrimalSharedKtor_utilsAttributeKey<T>, PrimalSharedKtor_httpUrlCompanion, PrimalSharedKtor_httpUrl, PrimalSharedKtor_httpURLProtocolCompanion, PrimalSharedKtor_httpURLProtocol, PrimalSharedKtor_httpURLBuilderCompanion, PrimalSharedKtor_httpURLBuilder, PrimalSharedKtor_httpOutgoingContentWriteChannelContent, PrimalSharedKtor_httpOutgoingContentReadChannelContent, PrimalSharedKtor_httpOutgoingContentProtocolUpgrade, PrimalSharedKtor_httpOutgoingContentNoContent, PrimalSharedKtor_httpOutgoingContentContentWrapper, PrimalSharedKtor_httpOutgoingContentByteArrayContent, PrimalSharedKtor_httpOutgoingContent, PrimalSharedKtor_httpHttpStatusCodeCompanion, PrimalSharedKtor_httpHttpStatusCode, PrimalSharedKtor_httpHttpProtocolVersionCompanion, PrimalSharedKtor_httpHttpProtocolVersion, PrimalSharedKtor_httpHttpMethodCompanion, PrimalSharedKtor_httpHttpMethod, PrimalSharedKtor_httpHeadersBuilder, PrimalSharedKtor_httpHeaderValueWithParametersCompanion, PrimalSharedKtor_httpHeaderValueWithParameters, PrimalSharedKtor_httpHeaderValueParam, PrimalSharedKtor_httpContentTypeCompanion, PrimalSharedKtor_httpContentType, PrimalSharedKtor_eventsEvents, PrimalSharedKtor_eventsEventDefinition<T>, PrimalSharedKtor_client_coreProxyConfig, PrimalSharedKtor_client_coreHttpSendPipelinePhases, PrimalSharedKtor_client_coreHttpSendPipeline, PrimalSharedKtor_client_coreHttpResponsePipelinePhases, PrimalSharedKtor_client_coreHttpResponsePipeline, PrimalSharedKtor_client_coreHttpResponseData, PrimalSharedKtor_client_coreHttpResponseContainer, PrimalSharedKtor_client_coreHttpResponse, PrimalSharedKtor_client_coreHttpRequestPipelinePhases, PrimalSharedKtor_client_coreHttpRequestPipeline, PrimalSharedKtor_client_coreHttpRequestData, PrimalSharedKtor_client_coreHttpRequestBuilderCompanion, PrimalSharedKtor_client_coreHttpRequestBuilder, PrimalSharedKtor_client_coreHttpReceivePipelinePhases, PrimalSharedKtor_client_coreHttpReceivePipeline, PrimalSharedKtor_client_coreHttpClientEngineConfig, PrimalSharedKtor_client_coreHttpClientConfig<T>, PrimalSharedKtor_client_coreHttpClientCallCompanion, PrimalSharedKtor_client_coreHttpClientCall, PrimalSharedKtor_client_coreHttpClient, PrimalSharedKotlinx_serialization_jsonJsonPrimitiveCompanion, PrimalSharedKotlinx_serialization_jsonJsonPrimitive, PrimalSharedKotlinx_serialization_jsonJsonNull, PrimalSharedKotlinx_serialization_jsonJsonElementCompanion, PrimalSharedKotlinx_serialization_jsonJsonElement, PrimalSharedKotlinx_serialization_coreStructureKindOBJECT, PrimalSharedKotlinx_serialization_coreStructureKindMAP, PrimalSharedKotlinx_serialization_coreStructureKindLIST, PrimalSharedKotlinx_serialization_coreStructureKindCLASS, PrimalSharedKotlinx_serialization_coreStructureKind, PrimalSharedKotlinx_serialization_coreSerializersModule, PrimalSharedKotlinx_serialization_coreSerialKindENUM, PrimalSharedKotlinx_serialization_coreSerialKindCONTEXTUAL, PrimalSharedKotlinx_serialization_coreSerialKind, PrimalSharedKotlinx_serialization_corePrimitiveKindSTRING, PrimalSharedKotlinx_serialization_corePrimitiveKindSHORT, PrimalSharedKotlinx_serialization_corePrimitiveKindLONG, PrimalSharedKotlinx_serialization_corePrimitiveKindINT, PrimalSharedKotlinx_serialization_corePrimitiveKindFLOAT, PrimalSharedKotlinx_serialization_corePrimitiveKindDOUBLE, PrimalSharedKotlinx_serialization_corePrimitiveKindCHAR, PrimalSharedKotlinx_serialization_corePrimitiveKindBYTE, PrimalSharedKotlinx_serialization_corePrimitiveKindBOOLEAN, PrimalSharedKotlinx_serialization_corePrimitiveKind, PrimalSharedKotlinx_serialization_corePolymorphicKindSEALED, PrimalSharedKotlinx_serialization_corePolymorphicKindOPEN, PrimalSharedKotlinx_serialization_corePolymorphicKind, PrimalSharedKotlinx_io_coreBuffer, PrimalSharedKotlinx_datetimeInstantCompanion, PrimalSharedKotlinx_datetimeInstant, PrimalSharedKotlinx_coroutines_coreCoroutineDispatcherKey, PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher, PrimalSharedKotlinUuidCompanion, PrimalSharedKotlinUuid, PrimalSharedKotlinUnit, PrimalSharedKotlinTriple<A, B, C>, PrimalSharedKotlinThrowable, PrimalSharedKotlinRuntimeException, PrimalSharedKotlinPair<A, B>, PrimalSharedKotlinNothing, PrimalSharedKotlinLongRangeCompanion, PrimalSharedKotlinLongRange, PrimalSharedKotlinLongProgressionCompanion, PrimalSharedKotlinLongProgression, PrimalSharedKotlinLongIterator, PrimalSharedKotlinKVariance, PrimalSharedKotlinKTypeProjectionCompanion, PrimalSharedKotlinKTypeProjection, PrimalSharedKotlinIntRangeCompanion, PrimalSharedKotlinIntRange, PrimalSharedKotlinIntProgressionCompanion, PrimalSharedKotlinIntProgression, PrimalSharedKotlinIntIterator, PrimalSharedKotlinIllegalStateException, PrimalSharedKotlinIllegalArgumentException, PrimalSharedKotlinException, PrimalSharedKotlinEnumCompanion, PrimalSharedKotlinEnum<E>, PrimalSharedKotlinCancellationException, PrimalSharedKotlinByteIterator, PrimalSharedKotlinByteArray, PrimalSharedKotlinArray<T>, PrimalSharedKotlinAbstractCoroutineContextKey<B, E>, PrimalSharedKotlinAbstractCoroutineContextElement, PrimalSharedJsonObjectMappersKt, PrimalSharedIosPrimalBlossomUploadService, PrimalSharedInvalidNostrPrivateKeyException, PrimalSharedInvalidLud16Exception, PrimalSharedInt, PrimalSharedHighlightData, PrimalSharedHighlight, PrimalSharedHashtagUtilsKt, PrimalSharedGetInfoResponsePayloadCompanion, PrimalSharedGetInfoResponsePayload, PrimalSharedGetBalanceResponsePayloadCompanion, PrimalSharedGetBalanceResponsePayload, PrimalSharedFollowPackProfileData, PrimalSharedFollowPack, PrimalSharedFloat, PrimalSharedFileTypeVideo, PrimalSharedFileTypeImage, PrimalSharedFileTypeDocument, PrimalSharedFileTypeCredentials, PrimalSharedFileType, PrimalSharedFileMetadata, PrimalSharedFeedSpecKind, PrimalSharedFeedRepositoryCompanion, PrimalSharedFeedPostStats, PrimalSharedFeedPostRepostInfo, PrimalSharedFeedPostAuthor, PrimalSharedFeedPost, PrimalSharedFeedPageSnapshot, PrimalSharedFeedKindKt, PrimalSharedFeedExtensionsKt, PrimalSharedExploreZapNoteData, PrimalSharedExploreTrendingTopic, PrimalSharedExplorePeopleData, PrimalSharedEventZapCompanion, PrimalSharedEventZap, PrimalSharedEventUriType, PrimalSharedEventUriNostrType, PrimalSharedEventUriNostrReferenceCompanion, PrimalSharedEventUriNostrReference, PrimalSharedEventRelayHints, PrimalSharedEventLinkPreviewData, PrimalSharedEventLinkCompanion, PrimalSharedEventLink, PrimalSharedDvmFeed, PrimalSharedDouble, PrimalSharedDirectMessage, PrimalSharedDMConversation, PrimalSharedCryptoUtils, PrimalSharedConversionUtilsKt, PrimalSharedConversationRelationCompanion, PrimalSharedConversationRelation, PrimalSharedContentZapDefaultKt, PrimalSharedContentZapDefaultCompanion, PrimalSharedContentZapDefault, PrimalSharedContentZapConfigItemKt, PrimalSharedContentZapConfigItemCompanion, PrimalSharedContentZapConfigItem, PrimalSharedContentProfilePremiumInfoCompanion, PrimalSharedContentProfilePremiumInfo, PrimalSharedContentPrimalPagingCompanion, PrimalSharedContentPrimalPaging, PrimalSharedContentMetadataCompanion, PrimalSharedContentMetadata, PrimalSharedContentAppSettingsCompanion, PrimalSharedContentAppSettings, PrimalSharedConstantsKt, PrimalSharedCdnResourceVariantCompanion, PrimalSharedCdnResourceVariant, PrimalSharedCdnResource, PrimalSharedCdnImageCompanion, PrimalSharedCdnImage, PrimalSharedByte, PrimalSharedBoolean, PrimalSharedBookmarkType, PrimalSharedBlossomUtilsKt, PrimalSharedBlossomUploadException, PrimalSharedBlossomMirrorException, PrimalSharedBlossomException, PrimalSharedBlossomApiFactory, PrimalSharedBlobDescriptorKt, PrimalSharedBlobDescriptorCompanion, PrimalSharedBlobDescriptor, PrimalSharedBignumSign, PrimalSharedBignumRoundingMode, PrimalSharedBignumModularQuotientAndRemainder, PrimalSharedBignumModularBigIntegerCompanion, PrimalSharedBignumModularBigInteger, PrimalSharedBignumDecimalModeCompanion, PrimalSharedBignumDecimalMode, PrimalSharedBignumBigIntegerSqareRootAndRemainder, PrimalSharedBignumBigIntegerQuotientAndRemainder, PrimalSharedBignumBigIntegerCompanion, PrimalSharedBignumBigIntegerBigIntegerRange, PrimalSharedBignumBigInteger, PrimalSharedBignumBigDecimalCompanion, PrimalSharedBignumBigDecimal, PrimalSharedBech32Encoding, PrimalSharedBech32, PrimalSharedBase, PrimalSharedArticleUtilsKt, PrimalSharedArticle, PrimalSharedAppConfigCompanion, PrimalSharedAppConfig, NSString, NSSet<ObjectType>, NSObject, NSNumber, NSMutableSet<ObjectType>, NSMutableDictionary<KeyType, ObjectType>, NSMutableArray<ObjectType>, NSError, NSDictionary<KeyType, ObjectType>, NSData, NSArray<ObjectType>;

@protocol PrimalSharedUtilsDispatcherProvider, PrimalSharedUserDataCleanupRepository, PrimalSharedSkie_DispatcherDelegate, PrimalSharedPublicBookmarksRepository, PrimalSharedProfileRepository, PrimalSharedPrimalPublisher, PrimalSharedPrimalApiClient, PrimalSharedOkioSource, PrimalSharedOkioSink, PrimalSharedOkioCloseable, PrimalSharedOkioBufferedSource, PrimalSharedOkioBufferedSink, PrimalSharedNwcApi, PrimalSharedNotificationRepository, PrimalSharedNostrZapperFactory, PrimalSharedNostrZapper, PrimalSharedNostrSocketClient, PrimalSharedNostrEventSignatureHandler, PrimalSharedNostrEventPublisher, PrimalSharedNostrEventImporter, PrimalSharedMutedItemRepository, PrimalSharedMessageCipher, PrimalSharedKtor_utilsStringValuesBuilder, PrimalSharedKtor_utilsStringValues, PrimalSharedKtor_utilsAttributes, PrimalSharedKtor_ioJvmSerializable, PrimalSharedKtor_ioCloseable, PrimalSharedKtor_ioByteWriteChannel, PrimalSharedKtor_ioByteReadChannel, PrimalSharedKtor_httpParametersBuilder, PrimalSharedKtor_httpParameters, PrimalSharedKtor_httpHttpMessageBuilder, PrimalSharedKtor_httpHttpMessage, PrimalSharedKtor_httpHeaders, PrimalSharedKtor_client_coreHttpRequest, PrimalSharedKtor_client_coreHttpClientPlugin, PrimalSharedKtor_client_coreHttpClientEngineCapability, PrimalSharedKtor_client_coreHttpClientEngine, PrimalSharedKotlinx_serialization_coreSerializersModuleCollector, PrimalSharedKotlinx_serialization_coreSerializationStrategy, PrimalSharedKotlinx_serialization_coreSerialDescriptor, PrimalSharedKotlinx_serialization_coreKSerializer, PrimalSharedKotlinx_serialization_coreEncoder, PrimalSharedKotlinx_serialization_coreDeserializationStrategy, PrimalSharedKotlinx_serialization_coreDecoder, PrimalSharedKotlinx_serialization_coreCompositeEncoder, PrimalSharedKotlinx_serialization_coreCompositeDecoder, PrimalSharedKotlinx_io_coreSource, PrimalSharedKotlinx_io_coreSink, PrimalSharedKotlinx_io_coreRawSource, PrimalSharedKotlinx_io_coreRawSink, PrimalSharedKotlinx_datetimeDateTimeFormat, PrimalSharedKotlinx_coroutines_coreStateFlow, PrimalSharedKotlinx_coroutines_coreSharedFlow, PrimalSharedKotlinx_coroutines_coreSelectInstance, PrimalSharedKotlinx_coroutines_coreSelectClause2, PrimalSharedKotlinx_coroutines_coreSelectClause1, PrimalSharedKotlinx_coroutines_coreSelectClause0, PrimalSharedKotlinx_coroutines_coreSelectClause, PrimalSharedKotlinx_coroutines_coreRunnable, PrimalSharedKotlinx_coroutines_coreParentJob, PrimalSharedKotlinx_coroutines_coreMutableStateFlow, PrimalSharedKotlinx_coroutines_coreMutableSharedFlow, PrimalSharedKotlinx_coroutines_coreJob, PrimalSharedKotlinx_coroutines_coreFlowCollector, PrimalSharedKotlinx_coroutines_coreFlow, PrimalSharedKotlinx_coroutines_coreDisposableHandle, PrimalSharedKotlinx_coroutines_coreCoroutineScope, PrimalSharedKotlinx_coroutines_coreChildJob, PrimalSharedKotlinx_coroutines_coreChildHandle, PrimalSharedKotlinSuspendFunction2, PrimalSharedKotlinSuspendFunction1, PrimalSharedKotlinSuspendFunction0, PrimalSharedKotlinSequence, PrimalSharedKotlinOpenEndRange, PrimalSharedKotlinMapEntry, PrimalSharedKotlinKType, PrimalSharedKotlinKDeclarationContainer, PrimalSharedKotlinKClassifier, PrimalSharedKotlinKClass, PrimalSharedKotlinKAnnotatedElement, PrimalSharedKotlinIterator, PrimalSharedKotlinIterable, PrimalSharedKotlinFunction, PrimalSharedKotlinCoroutineContextKey, PrimalSharedKotlinCoroutineContextElement, PrimalSharedKotlinCoroutineContext, PrimalSharedKotlinContinuationInterceptor, PrimalSharedKotlinContinuation, PrimalSharedKotlinComparator, PrimalSharedKotlinComparable, PrimalSharedKotlinClosedRange, PrimalSharedKotlinAutoCloseable, PrimalSharedKotlinAppendable, PrimalSharedKotlinAnnotation, PrimalSharedHighlightRepository, PrimalSharedFileTypeMatcher, PrimalSharedFeedsRepository, PrimalSharedFeedRepository, PrimalSharedExploreRepository, PrimalSharedEventUriRepository, PrimalSharedEventRepository, PrimalSharedEventRelayHintsRepository, PrimalSharedEventInteractionRepository, PrimalSharedChatRepository, PrimalSharedCachingImportRepository, PrimalSharedBlossomServerListProvider, PrimalSharedBlossomApi, PrimalSharedBignumByteArraySerializable, PrimalSharedBignumByteArrayDeserializable, PrimalSharedBignumBitwiseCapable, PrimalSharedBignumBigNumberUtil, PrimalSharedBignumBigNumberCreator, PrimalSharedBignumBigNumber, PrimalSharedArticleRepository, NSCopying;

// Due to an Obj-C/Swift interop limitation, SKIE cannot generate Swift types with a lambda type argument.
// Example of such type is: A<() -> Unit> where A<T> is a generic class.
// To avoid compilation errors SKIE replaces these type arguments with __SkieLambdaErrorType, resulting in A<__SkieLambdaErrorType>.
// Generated declarations that reference __SkieLambdaErrorType cannot be called in any way and the __SkieLambdaErrorType class cannot be used.
// The original declarations can still be used in the same way as other declarations hidden by SKIE (and with the same limitations as without SKIE).
@interface __SkieLambdaErrorType : NSObject
- (instancetype _Nonnull)init __attribute__((unavailable));
+ (instancetype _Nonnull)new __attribute__((unavailable));
@end

// Due to an Obj-C/Swift interop limitation, SKIE cannot generate Swift code that uses external Obj-C types for which SKIE doesn't know a fully qualified name.
// This problem occurs when custom Cinterop bindings are used because those do not contain the name of the Framework that provides implementation for those binding.
// The name can be configured manually using the SKIE Gradle configuration key 'ClassInterop.CInteropFrameworkName' in the same way as other SKIE features.
// To avoid compilation errors SKIE replaces types with unknown Framework name with __SkieUnknownCInteropFrameworkErrorType.
// Generated declarations that reference __SkieUnknownCInteropFrameworkErrorType cannot be called in any way and the __SkieUnknownCInteropFrameworkErrorType class cannot be used.
@interface __SkieUnknownCInteropFrameworkErrorType : NSObject
- (instancetype _Nonnull)init __attribute__((unavailable));
+ (instancetype _Nonnull)new __attribute__((unavailable));
@end


NS_ASSUME_NONNULL_BEGIN
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunknown-warning-option"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
#pragma clang diagnostic ignored "-Wnullability"

#pragma push_macro("_Nullable_result")
#if !__has_feature(nullability_nullable_result)
#undef _Nullable_result
#define _Nullable_result _Nullable
#endif

__attribute__((swift_name("KotlinBase")))
@interface PrimalSharedBase : NSObject
- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
+ (void)initialize __attribute__((objc_requires_super));
@end

@interface PrimalSharedBase (PrimalSharedBaseCopying) <NSCopying>
@end

__attribute__((swift_name("KotlinMutableSet")))
@interface PrimalSharedMutableSet<ObjectType> : NSMutableSet<ObjectType>
@end

__attribute__((swift_name("KotlinMutableDictionary")))
@interface PrimalSharedMutableDictionary<KeyType, ObjectType> : NSMutableDictionary<KeyType, ObjectType>
@end

@interface NSError (NSErrorPrimalSharedKotlinException)
@property (readonly) id _Nullable kotlinException;
@end

__attribute__((swift_name("KotlinNumber")))
@interface PrimalSharedNumber : NSNumber
- (instancetype)initWithChar:(char)value __attribute__((unavailable));
- (instancetype)initWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
- (instancetype)initWithShort:(short)value __attribute__((unavailable));
- (instancetype)initWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
- (instancetype)initWithInt:(int)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
- (instancetype)initWithLong:(long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
- (instancetype)initWithLongLong:(long long)value __attribute__((unavailable));
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
- (instancetype)initWithFloat:(float)value __attribute__((unavailable));
- (instancetype)initWithDouble:(double)value __attribute__((unavailable));
- (instancetype)initWithBool:(BOOL)value __attribute__((unavailable));
- (instancetype)initWithInteger:(NSInteger)value __attribute__((unavailable));
- (instancetype)initWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
+ (instancetype)numberWithChar:(char)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedChar:(unsigned char)value __attribute__((unavailable));
+ (instancetype)numberWithShort:(short)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedShort:(unsigned short)value __attribute__((unavailable));
+ (instancetype)numberWithInt:(int)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInt:(unsigned int)value __attribute__((unavailable));
+ (instancetype)numberWithLong:(long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLong:(unsigned long)value __attribute__((unavailable));
+ (instancetype)numberWithLongLong:(long long)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value __attribute__((unavailable));
+ (instancetype)numberWithFloat:(float)value __attribute__((unavailable));
+ (instancetype)numberWithDouble:(double)value __attribute__((unavailable));
+ (instancetype)numberWithBool:(BOOL)value __attribute__((unavailable));
+ (instancetype)numberWithInteger:(NSInteger)value __attribute__((unavailable));
+ (instancetype)numberWithUnsignedInteger:(NSUInteger)value __attribute__((unavailable));
@end

__attribute__((swift_name("KotlinByte")))
@interface PrimalSharedByte : PrimalSharedNumber
- (instancetype)initWithChar:(char)value;
+ (instancetype)numberWithChar:(char)value;
@end

__attribute__((swift_name("KotlinUByte")))
@interface PrimalSharedUByte : PrimalSharedNumber
- (instancetype)initWithUnsignedChar:(unsigned char)value;
+ (instancetype)numberWithUnsignedChar:(unsigned char)value;
@end

__attribute__((swift_name("KotlinShort")))
@interface PrimalSharedShort : PrimalSharedNumber
- (instancetype)initWithShort:(short)value;
+ (instancetype)numberWithShort:(short)value;
@end

__attribute__((swift_name("KotlinUShort")))
@interface PrimalSharedUShort : PrimalSharedNumber
- (instancetype)initWithUnsignedShort:(unsigned short)value;
+ (instancetype)numberWithUnsignedShort:(unsigned short)value;
@end

__attribute__((swift_name("KotlinInt")))
@interface PrimalSharedInt : PrimalSharedNumber
- (instancetype)initWithInt:(int)value;
+ (instancetype)numberWithInt:(int)value;
@end

__attribute__((swift_name("KotlinUInt")))
@interface PrimalSharedUInt : PrimalSharedNumber
- (instancetype)initWithUnsignedInt:(unsigned int)value;
+ (instancetype)numberWithUnsignedInt:(unsigned int)value;
@end

__attribute__((swift_name("KotlinLong")))
@interface PrimalSharedLong : PrimalSharedNumber
- (instancetype)initWithLongLong:(long long)value;
+ (instancetype)numberWithLongLong:(long long)value;
@end

__attribute__((swift_name("KotlinULong")))
@interface PrimalSharedULong : PrimalSharedNumber
- (instancetype)initWithUnsignedLongLong:(unsigned long long)value;
+ (instancetype)numberWithUnsignedLongLong:(unsigned long long)value;
@end

__attribute__((swift_name("KotlinFloat")))
@interface PrimalSharedFloat : PrimalSharedNumber
- (instancetype)initWithFloat:(float)value;
+ (instancetype)numberWithFloat:(float)value;
@end

__attribute__((swift_name("KotlinDouble")))
@interface PrimalSharedDouble : PrimalSharedNumber
- (instancetype)initWithDouble:(double)value;
+ (instancetype)numberWithDouble:(double)value;
@end

__attribute__((swift_name("KotlinBoolean")))
@interface PrimalSharedBoolean : PrimalSharedNumber
- (instancetype)initWithBool:(BOOL)value;
+ (instancetype)numberWithBool:(BOOL)value;
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieColdFlowIterator")))
@interface PrimalSharedSkieColdFlowIterator<E> : PrimalSharedBase
- (instancetype)initWithFlow:(id<PrimalSharedKotlinx_coroutines_coreFlow>)flow __attribute__((swift_name("init(flow:)"))) __attribute__((objc_designated_initializer));
- (void)cancel __attribute__((swift_name("cancel()")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)hasNextWithCompletionHandler:(void (^)(PrimalSharedBoolean * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("hasNext(completionHandler:)")));
- (E _Nullable)next __attribute__((swift_name("next()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlow")))
@protocol PrimalSharedKotlinx_coroutines_coreFlow
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinFlow")))
@interface PrimalSharedSkieKotlinFlow<__covariant T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreFlow>
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSharedFlow")))
@protocol PrimalSharedKotlinx_coroutines_coreSharedFlow <PrimalSharedKotlinx_coroutines_coreFlow>
@required
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreFlowCollector")))
@protocol PrimalSharedKotlinx_coroutines_coreFlowCollector
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(id _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreMutableSharedFlow")))
@protocol PrimalSharedKotlinx_coroutines_coreMutableSharedFlow <PrimalSharedKotlinx_coroutines_coreSharedFlow, PrimalSharedKotlinx_coroutines_coreFlowCollector>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (BOOL)tryEmitValue:(id _Nullable)value __attribute__((swift_name("tryEmit(value:)")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinMutableSharedFlow")))
@interface PrimalSharedSkieKotlinMutableSharedFlow<T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreMutableSharedFlow>
@property (readonly) NSArray<T> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreMutableSharedFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(T)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (BOOL)tryEmitValue:(T)value __attribute__((swift_name("tryEmit(value:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreStateFlow")))
@protocol PrimalSharedKotlinx_coroutines_coreStateFlow <PrimalSharedKotlinx_coroutines_coreSharedFlow>
@required
@property (readonly) id _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreMutableStateFlow")))
@protocol PrimalSharedKotlinx_coroutines_coreMutableStateFlow <PrimalSharedKotlinx_coroutines_coreStateFlow, PrimalSharedKotlinx_coroutines_coreMutableSharedFlow>
@required
- (void)setValue:(id _Nullable)value __attribute__((swift_name("setValue(_:)")));
- (BOOL)compareAndSetExpect:(id _Nullable)expect update:(id _Nullable)update __attribute__((swift_name("compareAndSet(expect:update:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinMutableStateFlow")))
@interface PrimalSharedSkieKotlinMutableStateFlow<T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreMutableStateFlow>
@property (readonly) NSArray<T> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
@property T value __attribute__((swift_name("value")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreMutableStateFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
- (BOOL)compareAndSetExpect:(T)expect update:(T)update __attribute__((swift_name("compareAndSet(expect:update:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(T)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (BOOL)tryEmitValue:(T)value __attribute__((swift_name("tryEmit(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinOptionalFlow")))
@interface PrimalSharedSkieKotlinOptionalFlow<__covariant T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreFlow>
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinOptionalMutableSharedFlow")))
@interface PrimalSharedSkieKotlinOptionalMutableSharedFlow<T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreMutableSharedFlow>
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreMutableSharedFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(T _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (BOOL)tryEmitValue:(T _Nullable)value __attribute__((swift_name("tryEmit(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinOptionalMutableStateFlow")))
@interface PrimalSharedSkieKotlinOptionalMutableStateFlow<T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreMutableStateFlow>
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreStateFlow> subscriptionCount __attribute__((swift_name("subscriptionCount")));
@property T _Nullable value __attribute__((swift_name("value")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreMutableStateFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
- (BOOL)compareAndSetExpect:(T _Nullable)expect update:(T _Nullable)update __attribute__((swift_name("compareAndSet(expect:update:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)emitValue:(T _Nullable)value completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("emit(value:completionHandler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
- (void)resetReplayCache __attribute__((swift_name("resetReplayCache()")));
- (BOOL)tryEmitValue:(T _Nullable)value __attribute__((swift_name("tryEmit(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinOptionalSharedFlow")))
@interface PrimalSharedSkieKotlinOptionalSharedFlow<__covariant T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreSharedFlow>
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreSharedFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinOptionalStateFlow")))
@interface PrimalSharedSkieKotlinOptionalStateFlow<__covariant T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreStateFlow>
@property (readonly) NSArray<id> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) T _Nullable value __attribute__((swift_name("value")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreStateFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinSharedFlow")))
@interface PrimalSharedSkieKotlinSharedFlow<__covariant T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreSharedFlow>
@property (readonly) NSArray<T> *replayCache __attribute__((swift_name("replayCache")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreSharedFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SkieKotlinStateFlow")))
@interface PrimalSharedSkieKotlinStateFlow<__covariant T> : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreStateFlow>
@property (readonly) NSArray<T> *replayCache __attribute__((swift_name("replayCache")));
@property (readonly) T value __attribute__((swift_name("value")));
- (instancetype)initWithDelegate:(id<PrimalSharedKotlinx_coroutines_coreStateFlow>)delegate __attribute__((swift_name("init(_:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)collectCollector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("collect(collector:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Skie_CancellationHandler")))
@interface PrimalSharedSkie_CancellationHandler : PrimalSharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (void)cancel __attribute__((swift_name("cancel()")));
@end

__attribute__((swift_name("Skie_DispatcherDelegate")))
@protocol PrimalSharedSkie_DispatcherDelegate
@required
- (void)dispatchBlock:(id<PrimalSharedKotlinx_coroutines_coreRunnable>)block __attribute__((swift_name("dispatch(block:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Skie_SuspendHandler")))
@interface PrimalSharedSkie_SuspendHandler : PrimalSharedBase
- (instancetype)initWithCancellationHandler:(PrimalSharedSkie_CancellationHandler *)cancellationHandler dispatcherDelegate:(id<PrimalSharedSkie_DispatcherDelegate>)dispatcherDelegate onResult:(void (^)(PrimalSharedSkie_SuspendResult *))onResult __attribute__((swift_name("init(cancellationHandler:dispatcherDelegate:onResult:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("Skie_SuspendResult")))
@interface PrimalSharedSkie_SuspendResult : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Skie_SuspendResult.Canceled")))
@interface PrimalSharedSkie_SuspendResultCanceled : PrimalSharedSkie_SuspendResult
@property (class, readonly, getter=shared) PrimalSharedSkie_SuspendResultCanceled *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)canceled __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Skie_SuspendResult.Error")))
@interface PrimalSharedSkie_SuspendResultError : PrimalSharedSkie_SuspendResult
@property (readonly) NSError *error __attribute__((swift_name("error")));
- (instancetype)initWithError:(NSError *)error __attribute__((swift_name("init(error:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedSkie_SuspendResultError *)doCopyError:(NSError *)error __attribute__((swift_name("doCopy(error:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Skie_SuspendResult.Success")))
@interface PrimalSharedSkie_SuspendResultSuccess : PrimalSharedSkie_SuspendResult
@property (readonly) id _Nullable value __attribute__((swift_name("value")));
- (instancetype)initWithValue:(id _Nullable)value __attribute__((swift_name("init(value:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedSkie_SuspendResultSuccess *)doCopyValue:(id _Nullable)value __attribute__((swift_name("doCopy(value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FileType")))
@interface PrimalSharedFileType : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedFileType *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)fileType __attribute__((swift_name("init()")));
- (PrimalSharedMime * _Nullable)detectBuffer:(PrimalSharedKotlinByteArray *)buffer __attribute__((swift_name("detect(buffer:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FileType.Credentials")))
@interface PrimalSharedFileTypeCredentials : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedFileTypeCredentials *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedMime *Jks __attribute__((swift_name("Jks")));
@property (readonly) PrimalSharedMime *Kdbx __attribute__((swift_name("Kdbx")));
@property (readonly) PrimalSharedMime *OpenSshPrivateKey __attribute__((swift_name("OpenSshPrivateKey")));
@property (readonly) PrimalSharedMime *Pem __attribute__((swift_name("Pem")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)credentials __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FileType.Document")))
@interface PrimalSharedFileTypeDocument : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedFileTypeDocument *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedMime *Pdf __attribute__((swift_name("Pdf")));
@property (readonly) PrimalSharedMime *Rtf __attribute__((swift_name("Rtf")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)document __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FileType.Image")))
@interface PrimalSharedFileTypeImage : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedFileTypeImage *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedMime *Avif __attribute__((swift_name("Avif")));
@property (readonly) PrimalSharedMime *Bmp __attribute__((swift_name("Bmp")));
@property (readonly) PrimalSharedMime *Dwg __attribute__((swift_name("Dwg")));
@property (readonly) PrimalSharedMime *Exr __attribute__((swift_name("Exr")));
@property (readonly) PrimalSharedMime *Gif __attribute__((swift_name("Gif")));
@property (readonly) PrimalSharedMime *Heif __attribute__((swift_name("Heif")));
@property (readonly) PrimalSharedMime *Ico __attribute__((swift_name("Ico")));
@property (readonly) PrimalSharedMime *Jpeg __attribute__((swift_name("Jpeg")));
@property (readonly) PrimalSharedMime *Jpeg2000 __attribute__((swift_name("Jpeg2000")));
@property (readonly) PrimalSharedMime *Jxr __attribute__((swift_name("Jxr")));
@property (readonly) PrimalSharedMime *Png __attribute__((swift_name("Png")));
@property (readonly) PrimalSharedMime *Psd __attribute__((swift_name("Psd")));
@property (readonly) PrimalSharedMime *Svg __attribute__((swift_name("Svg")));
@property (readonly) PrimalSharedMime *Tiff __attribute__((swift_name("Tiff")));
@property (readonly) PrimalSharedMime *Webp __attribute__((swift_name("Webp")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)image __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("FileTypeMatcher")))
@protocol PrimalSharedFileTypeMatcher
@required
- (BOOL)invokeBuffer:(PrimalSharedKotlinByteArray *)buffer __attribute__((swift_name("invoke(buffer:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FileType.Video")))
@interface PrimalSharedFileTypeVideo : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedFileTypeVideo *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedMime *Avi __attribute__((swift_name("Avi")));
@property (readonly) PrimalSharedMime *Flv __attribute__((swift_name("Flv")));
@property (readonly) PrimalSharedMime *M4v __attribute__((swift_name("M4v")));
@property (readonly) PrimalSharedMime *Mkv __attribute__((swift_name("Mkv")));
@property (readonly) PrimalSharedMime *Mov __attribute__((swift_name("Mov")));
@property (readonly) PrimalSharedMime *Mp4 __attribute__((swift_name("Mp4")));
@property (readonly) PrimalSharedMime *Mpeg __attribute__((swift_name("Mpeg")));
@property (readonly) PrimalSharedMime *Webm __attribute__((swift_name("Webm")));
@property (readonly) PrimalSharedMime *Wmv __attribute__((swift_name("Wmv")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)video __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Mime")))
@interface PrimalSharedMime : PrimalSharedBase
@property (readonly) PrimalSharedMimeSubtype *subtype __attribute__((swift_name("subtype")));
@property (readonly) PrimalSharedMimeType *type __attribute__((swift_name("type")));
- (instancetype)initWithType:(PrimalSharedMimeType *)type subtype:(PrimalSharedMimeSubtype *)subtype __attribute__((swift_name("init(type:subtype:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedMime *)doCopyType:(PrimalSharedMimeType *)type subtype:(PrimalSharedMimeSubtype *)subtype __attribute__((swift_name("doCopy(type:subtype:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSString *)toStringParameter:(PrimalSharedKotlinPair<NSString *, NSString *> *)parameter __attribute__((swift_name("toString(parameter:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Mime.Subtype")))
@interface PrimalSharedMimeSubtype : PrimalSharedBase
- (instancetype)initWithValue:(NSString *)value __attribute__((swift_name("init(value:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedMimeSubtype *)doCopyValue:(NSString *)value __attribute__((swift_name("doCopy(value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinComparable")))
@protocol PrimalSharedKotlinComparable
@required
- (int32_t)compareToOther:(id _Nullable)other __attribute__((swift_name("compareTo(other:)")));
@end

__attribute__((swift_name("KotlinEnum")))
@interface PrimalSharedKotlinEnum<E> : PrimalSharedBase <PrimalSharedKotlinComparable>
@property (class, readonly, getter=companion) PrimalSharedKotlinEnumCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) int32_t ordinal __attribute__((swift_name("ordinal")));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer));
- (int32_t)compareToOther:(E)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Mime.Type_")))
@interface PrimalSharedMimeType : PrimalSharedKotlinEnum<PrimalSharedMimeType *>
@property (class, readonly) PrimalSharedMimeType *application __attribute__((swift_name("application")));
@property (class, readonly) PrimalSharedMimeType *audio __attribute__((swift_name("audio")));
@property (class, readonly) PrimalSharedMimeType *font __attribute__((swift_name("font")));
@property (class, readonly) PrimalSharedMimeType *image __attribute__((swift_name("image")));
@property (class, readonly) PrimalSharedMimeType *model __attribute__((swift_name("model")));
@property (class, readonly) PrimalSharedMimeType *text __attribute__((swift_name("text")));
@property (class, readonly) PrimalSharedMimeType *video __attribute__((swift_name("video")));
@property (class, readonly) NSArray<PrimalSharedMimeType *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedMimeType *> *)values __attribute__((swift_name("values()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BlobDescriptor")))
@interface PrimalSharedBlobDescriptor : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedBlobDescriptorCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<NSArray<NSString *> *> * _Nullable nip94 __attribute__((swift_name("nip94")));
@property (readonly) NSString *sha256 __attribute__((swift_name("sha256")));
@property (readonly) int64_t sizeInBytes __attribute__((swift_name("sizeInBytes")));
@property (readonly) NSString * _Nullable type __attribute__((swift_name("type")));
@property (readonly) int64_t uploaded __attribute__((swift_name("uploaded")));
@property (readonly) NSString *url __attribute__((swift_name("url")));
- (instancetype)initWithUrl:(NSString *)url sha256:(NSString *)sha256 sizeInBytes:(int64_t)sizeInBytes type:(NSString * _Nullable)type uploaded:(int64_t)uploaded nip94:(NSArray<NSArray<NSString *> *> * _Nullable)nip94 __attribute__((swift_name("init(url:sha256:sizeInBytes:type:uploaded:nip94:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedBlobDescriptor *)doCopyUrl:(NSString *)url sha256:(NSString *)sha256 sizeInBytes:(int64_t)sizeInBytes type:(NSString * _Nullable)type uploaded:(int64_t)uploaded nip94:(NSArray<NSArray<NSString *> *> * _Nullable)nip94 __attribute__((swift_name("doCopy(url:sha256:sizeInBytes:type:uploaded:nip94:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="size")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BlobDescriptor.Companion")))
@interface PrimalSharedBlobDescriptorCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedBlobDescriptorCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("BlossomApi")))
@protocol PrimalSharedBlossomApi
@required

/**
 * @note This method converts instances of UploadRequirementException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)headMediaAuthorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("headMedia(authorization:fileMetadata:completionHandler:)")));

/**
 * @note This method converts instances of UploadRequirementException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)headUploadAuthorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("headUpload(authorization:fileMetadata:completionHandler:)")));

/**
 * @note This method converts instances of BlossomUploadException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)putMediaAuthorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata bufferedSource:(id<PrimalSharedOkioBufferedSource>)bufferedSource onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress completionHandler:(void (^)(PrimalSharedBlobDescriptor * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("putMedia(authorization:fileMetadata:bufferedSource:onProgress:completionHandler:)")));

/**
 * @note This method converts instances of BlossomMirrorException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)putMirrorAuthorization:(NSString *)authorization fileUrl:(NSString *)fileUrl completionHandler:(void (^)(PrimalSharedBlobDescriptor * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("putMirror(authorization:fileUrl:completionHandler:)")));

/**
 * @note This method converts instances of BlossomUploadException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)putUploadAuthorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata bufferedSource:(id<PrimalSharedOkioBufferedSource>)bufferedSource onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress completionHandler:(void (^)(PrimalSharedBlobDescriptor * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("putUpload(authorization:fileMetadata:bufferedSource:onProgress:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BlossomApiFactory")))
@interface PrimalSharedBlossomApiFactory : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedBlossomApiFactory *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)blossomApiFactory __attribute__((swift_name("init()")));
- (id<PrimalSharedBlossomApi>)createBaseBlossomUrl:(NSString *)baseBlossomUrl __attribute__((swift_name("create(baseBlossomUrl:)")));
@end

__attribute__((swift_name("KotlinThrowable")))
@interface PrimalSharedKotlinThrowable : PrimalSharedBase
@property (readonly) PrimalSharedKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));

/**
 * @note annotations
 *   kotlin.experimental.ExperimentalNativeApi
*/
- (PrimalSharedKotlinArray<NSString *> *)getStackTrace __attribute__((swift_name("getStackTrace()")));
- (void)printStackTrace __attribute__((swift_name("printStackTrace()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSError *)asError __attribute__((swift_name("asError()")));
@end

__attribute__((swift_name("KotlinException")))
@interface PrimalSharedKotlinException : PrimalSharedKotlinThrowable
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinRuntimeException")))
@interface PrimalSharedKotlinRuntimeException : PrimalSharedKotlinException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("BlossomException")))
@interface PrimalSharedBlossomException : PrimalSharedKotlinRuntimeException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BlossomMirrorException")))
@interface PrimalSharedBlossomMirrorException : PrimalSharedBlossomException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("BlossomServerListProvider")))
@protocol PrimalSharedBlossomServerListProvider
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)provideBlossomServerListUserId:(NSString *)userId completionHandler:(void (^)(NSArray<NSString *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("provideBlossomServerList(userId:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BlossomUploadException")))
@interface PrimalSharedBlossomUploadException : PrimalSharedBlossomException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FileMetadata")))
@interface PrimalSharedFileMetadata : PrimalSharedBase
@property (readonly) NSString * _Nullable mimeType __attribute__((swift_name("mimeType")));
@property (readonly) NSString *sha256 __attribute__((swift_name("sha256")));
@property (readonly) int64_t sizeInBytes __attribute__((swift_name("sizeInBytes")));
- (instancetype)initWithSha256:(NSString *)sha256 sizeInBytes:(int64_t)sizeInBytes mimeType:(NSString * _Nullable)mimeType __attribute__((swift_name("init(sha256:sizeInBytes:mimeType:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFileMetadata *)doCopySha256:(NSString *)sha256 sizeInBytes:(int64_t)sizeInBytes mimeType:(NSString * _Nullable)mimeType __attribute__((swift_name("doCopy(sha256:sizeInBytes:mimeType:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("IosPrimalBlossomUploadService")))
@interface PrimalSharedIosPrimalBlossomUploadService : PrimalSharedBase
- (instancetype)initWithBlossomResolver:(id<PrimalSharedBlossomServerListProvider>)blossomResolver signatureHandler:(id<PrimalSharedNostrEventSignatureHandler> _Nullable)signatureHandler __attribute__((swift_name("init(blossomResolver:signatureHandler:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)uploadPath:(NSString *)path userId:(NSString *)userId onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress completionHandler:(void (^)(PrimalSharedUploadResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("upload(path:userId:onProgress:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)uploadPath:(NSString *)path userId:(NSString *)userId onSignRequested:(PrimalSharedNostrEvent *(^)(PrimalSharedNostrUnsignedEvent *))onSignRequested onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress completionHandler:(void (^)(PrimalSharedUploadResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("upload(path:userId:onSignRequested:onProgress:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrExtensions")))
@interface PrimalSharedNostrExtensions : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrExtensions *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)nostrExtensions __attribute__((swift_name("init()")));
- (PrimalSharedSignResultSigned *)buildNostrSignResultId:(NSString *)id pubKey:(NSString *)pubKey createdAt:(int64_t)createdAt kind:(int32_t)kind tags:(NSArray<NSArray<NSString *> *> *)tags content:(NSString *)content sig:(NSString *)sig __attribute__((swift_name("buildNostrSignResult(id:pubKey:createdAt:kind:tags:content:sig:)")));
- (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)mapAsJsonArrayTag:(NSArray<NSString *> *)tag __attribute__((swift_name("mapAsJsonArray(tag:)")));
- (NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)mapAsListOfJsonArrayTags:(NSArray<NSArray<NSString *> *> *)tags __attribute__((swift_name("mapAsListOfJsonArray(tags:)")));
- (NSArray<NSArray<NSString *> *> *)mapAsListOfListOfStringsTags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags __attribute__((swift_name("mapAsListOfListOfStrings(tags:)")));
- (NSArray<NSString *> *)mapAsListOfStringsTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)tag __attribute__((swift_name("mapAsListOfStrings(tag:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("UploadRequirementException")))
@interface PrimalSharedUploadRequirementException : PrimalSharedBlossomException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("UploadResult")))
@interface PrimalSharedUploadResult : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("UploadResult.Failed")))
@interface PrimalSharedUploadResultFailed : PrimalSharedUploadResult
@property (readonly) PrimalSharedBlossomException *error __attribute__((swift_name("error")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
- (instancetype)initWithError:(PrimalSharedBlossomException *)error message:(NSString * _Nullable)message __attribute__((swift_name("init(error:message:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedUploadResultFailed *)doCopyError:(PrimalSharedBlossomException *)error message:(NSString * _Nullable)message __attribute__((swift_name("doCopy(error:message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("UploadResult.Success")))
@interface PrimalSharedUploadResultSuccess : PrimalSharedUploadResult
@property (readonly) PrimalSharedNip94Metadata * _Nullable nip94 __attribute__((swift_name("nip94")));
@property (readonly) int64_t originalFileSize __attribute__((swift_name("originalFileSize")));
@property (readonly) NSString *originalHash __attribute__((swift_name("originalHash")));
@property (readonly) NSString *remoteUrl __attribute__((swift_name("remoteUrl")));
- (instancetype)initWithRemoteUrl:(NSString *)remoteUrl originalFileSize:(int64_t)originalFileSize originalHash:(NSString *)originalHash nip94:(PrimalSharedNip94Metadata * _Nullable)nip94 __attribute__((swift_name("init(remoteUrl:originalFileSize:originalHash:nip94:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedUploadResultSuccess *)doCopyRemoteUrl:(NSString *)remoteUrl originalFileSize:(int64_t)originalFileSize originalHash:(NSString *)originalHash nip94:(PrimalSharedNip94Metadata * _Nullable)nip94 __attribute__((swift_name("doCopy(remoteUrl:originalFileSize:originalHash:nip94:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalApiClientFactory")))
@interface PrimalSharedPrimalApiClientFactory : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPrimalApiClientFactory *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)primalApiClientFactory __attribute__((swift_name("init()")));
- (id<PrimalSharedPrimalApiClient>)createServerType:(PrimalSharedPrimalServerType *)serverType __attribute__((swift_name("create(serverType:)")));
- (id<PrimalSharedPrimalApiClient>)createDispatcherProvider:(id<PrimalSharedUtilsDispatcherProvider>)dispatcherProvider serverType:(PrimalSharedPrimalServerType *)serverType httpClient:(PrimalSharedKtor_client_coreHttpClient *)httpClient __attribute__((swift_name("create(dispatcherProvider:serverType:httpClient:)")));
- (id<PrimalSharedPrimalApiClient>)getDefaultServerType:(PrimalSharedPrimalServerType *)serverType __attribute__((swift_name("getDefault(serverType:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("InvalidLud16Exception")))
@interface PrimalSharedInvalidLud16Exception : PrimalSharedKotlinRuntimeException
@property (readonly) PrimalSharedKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
@property (readonly) NSString *lud16 __attribute__((swift_name("lud16")));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause lud16:(NSString *)lud16 __attribute__((swift_name("init(cause:lud16:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LightningAddressChecker")))
@interface PrimalSharedLightningAddressChecker : PrimalSharedBase
- (instancetype)initWithDispatcherProvider:(id<PrimalSharedUtilsDispatcherProvider>)dispatcherProvider httpClient:(PrimalSharedKtor_client_coreHttpClient *)httpClient __attribute__((swift_name("init(dispatcherProvider:httpClient:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)validateLightningAddressLud16:(NSString *)lud16 completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("validateLightningAddress(lud16:completionHandler:)")));
@end

__attribute__((swift_name("NwcApi")))
@protocol PrimalSharedNwcApi
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)getBalanceWithCompletionHandler:(void (^)(PrimalSharedNwcResult<PrimalSharedGetBalanceResponsePayload *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("getBalance(completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)getInfoWithCompletionHandler:(void (^)(PrimalSharedNwcResult<PrimalSharedGetInfoResponsePayload *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("getInfo(completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)listTransactionsParams:(PrimalSharedListTransactionsParams *)params completionHandler:(void (^)(PrimalSharedNwcResult<PrimalSharedListTransactionsResponsePayload *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("listTransactions(params:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)lookupInvoiceParams:(PrimalSharedLookupInvoiceParams *)params completionHandler:(void (^)(PrimalSharedNwcResult<PrimalSharedLookupInvoiceResponsePayload *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("lookupInvoice(params:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)makeInvoiceParams:(PrimalSharedMakeInvoiceParams *)params completionHandler:(void (^)(PrimalSharedNwcResult<PrimalSharedMakeInvoiceResponsePayload *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("makeInvoice(params:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)multiPayInvoiceParams:(NSArray<PrimalSharedPayInvoiceParams *> *)params completionHandler:(void (^)(PrimalSharedNwcResult<NSArray<PrimalSharedPayInvoiceResponsePayload *> *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("multiPayInvoice(params:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)multiPayKeysendParams:(NSArray<PrimalSharedPayKeysendParams *> *)params completionHandler:(void (^)(PrimalSharedNwcResult<NSArray<PrimalSharedPayKeysendResponsePayload *> *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("multiPayKeysend(params:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)payInvoiceParams:(PrimalSharedPayInvoiceParams *)params completionHandler:(void (^)(PrimalSharedNwcResult<PrimalSharedPayInvoiceResponsePayload *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("payInvoice(params:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)payKeysendParams:(PrimalSharedPayKeysendParams *)params completionHandler:(void (^)(PrimalSharedNwcResult<PrimalSharedPayKeysendResponsePayload *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("payKeysend(params:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcClientFactory")))
@interface PrimalSharedNwcClientFactory : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNwcClientFactory *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)nwcClientFactory __attribute__((swift_name("init()")));
- (id<PrimalSharedNwcApi>)createNwcApiClientNwcData:(PrimalSharedNostrWalletConnect *)nwcData __attribute__((swift_name("createNwcApiClient(nwcData:)")));
- (id<PrimalSharedNostrZapper>)createNwcNostrZapperNwcData:(PrimalSharedNostrWalletConnect *)nwcData __attribute__((swift_name("createNwcNostrZapper(nwcData:)")));
@end

__attribute__((swift_name("NwcResult")))
@interface PrimalSharedNwcResult<T> : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcResultFailure")))
@interface PrimalSharedNwcResultFailure<T> : PrimalSharedNwcResult<T>
@property (readonly) PrimalSharedKotlinException *error __attribute__((swift_name("error")));
- (instancetype)initWithError:(PrimalSharedKotlinException *)error __attribute__((swift_name("init(error:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNwcResultFailure<T> *)doCopyError:(PrimalSharedKotlinException *)error __attribute__((swift_name("doCopy(error:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcResultSuccess")))
@interface PrimalSharedNwcResultSuccess<T> : PrimalSharedNwcResult<T>
@property (readonly) T _Nullable result __attribute__((swift_name("result")));
- (instancetype)initWithResult:(T _Nullable)result __attribute__((swift_name("init(result:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNwcResultSuccess<T> *)doCopyResult:(T _Nullable)result __attribute__((swift_name("doCopy(result:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LightningPayRequest")))
@interface PrimalSharedLightningPayRequest : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedLightningPayRequestCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedBoolean * _Nullable allowsNostr __attribute__((swift_name("allowsNostr")));
@property (readonly) NSString *callback __attribute__((swift_name("callback")));
@property (readonly) PrimalSharedInt * _Nullable commentAllowed __attribute__((swift_name("commentAllowed")));
@property (readonly) PrimalSharedBoolean * _Nullable disposable __attribute__((swift_name("disposable")));
@property (readonly) uint64_t maxSendable __attribute__((swift_name("maxSendable")));
@property (readonly) NSString *metadata __attribute__((swift_name("metadata")));
@property (readonly) uint64_t minSendable __attribute__((swift_name("minSendable")));
@property (readonly) NSString * _Nullable nostrPubkey __attribute__((swift_name("nostrPubkey")));
@property (readonly) PrimalSharedPayerData * _Nullable payerData __attribute__((swift_name("payerData")));
@property (readonly) NSString *tag __attribute__((swift_name("tag")));
- (instancetype)initWithCallback:(NSString *)callback metadata:(NSString *)metadata minSendable:(uint64_t)minSendable maxSendable:(uint64_t)maxSendable tag:(NSString *)tag allowsNostr:(PrimalSharedBoolean * _Nullable)allowsNostr nostrPubkey:(NSString * _Nullable)nostrPubkey commentAllowed:(PrimalSharedInt * _Nullable)commentAllowed disposable:(PrimalSharedBoolean * _Nullable)disposable payerData:(PrimalSharedPayerData * _Nullable)payerData __attribute__((swift_name("init(callback:metadata:minSendable:maxSendable:tag:allowsNostr:nostrPubkey:commentAllowed:disposable:payerData:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedLightningPayRequest *)doCopyCallback:(NSString *)callback metadata:(NSString *)metadata minSendable:(uint64_t)minSendable maxSendable:(uint64_t)maxSendable tag:(NSString *)tag allowsNostr:(PrimalSharedBoolean * _Nullable)allowsNostr nostrPubkey:(NSString * _Nullable)nostrPubkey commentAllowed:(PrimalSharedInt * _Nullable)commentAllowed disposable:(PrimalSharedBoolean * _Nullable)disposable payerData:(PrimalSharedPayerData * _Nullable)payerData __attribute__((swift_name("doCopy(callback:metadata:minSendable:maxSendable:tag:allowsNostr:nostrPubkey:commentAllowed:disposable:payerData:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LightningPayRequest.Companion")))
@interface PrimalSharedLightningPayRequestCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedLightningPayRequestCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LightningPayResponse")))
@interface PrimalSharedLightningPayResponse : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedLightningPayResponseCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *pr __attribute__((swift_name("pr")));
- (instancetype)initWithPr:(NSString *)pr __attribute__((swift_name("init(pr:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedLightningPayResponse *)doCopyPr:(NSString *)pr __attribute__((swift_name("doCopy(pr:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (PrimalSharedPayInvoiceParams *)toNwcPayInvoiceParams __attribute__((swift_name("toNwcPayInvoiceParams()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (PrimalSharedNwcWalletRequest<PrimalSharedPayInvoiceParams *> *)toWalletPayRequest __attribute__((swift_name("toWalletPayRequest()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LightningPayResponse.Companion")))
@interface PrimalSharedLightningPayResponseCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedLightningPayResponseCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrWalletConnect")))
@interface PrimalSharedNostrWalletConnect : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedNostrWalletConnectCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedNostrWalletKeypair *keypair __attribute__((swift_name("keypair")));
@property (readonly) NSString * _Nullable lightningAddress __attribute__((swift_name("lightningAddress")));
@property (readonly) NSString *pubkey __attribute__((swift_name("pubkey")));
@property (readonly) NSArray<NSString *> *relays __attribute__((swift_name("relays")));
- (instancetype)initWithLightningAddress:(NSString * _Nullable)lightningAddress relays:(NSArray<NSString *> *)relays pubkey:(NSString *)pubkey keypair:(PrimalSharedNostrWalletKeypair *)keypair __attribute__((swift_name("init(lightningAddress:relays:pubkey:keypair:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrWalletConnect *)doCopyLightningAddress:(NSString * _Nullable)lightningAddress relays:(NSArray<NSString *> *)relays pubkey:(NSString *)pubkey keypair:(PrimalSharedNostrWalletKeypair *)keypair __attribute__((swift_name("doCopy(lightningAddress:relays:pubkey:keypair:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSString *)toStringUrl __attribute__((swift_name("toStringUrl()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrWalletConnect.Companion")))
@interface PrimalSharedNostrWalletConnectCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrWalletConnectCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrWalletKeypair")))
@interface PrimalSharedNostrWalletKeypair : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedNostrWalletKeypairCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *privateKey __attribute__((swift_name("privateKey")));
@property (readonly) NSString *pubkey __attribute__((swift_name("pubkey")));
- (instancetype)initWithPrivateKey:(NSString *)privateKey pubkey:(NSString *)pubkey __attribute__((swift_name("init(privateKey:pubkey:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrWalletKeypair *)doCopyPrivateKey:(NSString *)privateKey pubkey:(NSString *)pubkey __attribute__((swift_name("doCopy(privateKey:pubkey:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrWalletKeypair.Companion")))
@interface PrimalSharedNostrWalletKeypairCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrWalletKeypairCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcWalletRequest")))
@interface PrimalSharedNwcWalletRequest<T> : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedNwcWalletRequestCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *method __attribute__((swift_name("method")));
@property (readonly) T _Nullable params __attribute__((swift_name("params")));
- (instancetype)initWithMethod:(NSString *)method params:(T _Nullable)params __attribute__((swift_name("init(method:params:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNwcWalletRequest<T> *)doCopyMethod:(NSString *)method params:(T _Nullable)params __attribute__((swift_name("doCopy(method:params:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcWalletRequestCompanion")))
@interface PrimalSharedNwcWalletRequestCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNwcWalletRequestCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializerTypeParamsSerializers:(PrimalSharedKotlinArray<id<PrimalSharedKotlinx_serialization_coreKSerializer>> *)typeParamsSerializers __attribute__((swift_name("serializer(typeParamsSerializers:)")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializerTypeSerial0:(id<PrimalSharedKotlinx_serialization_coreKSerializer>)typeSerial0 __attribute__((swift_name("serializer(typeSerial0:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayerData")))
@interface PrimalSharedPayerData : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPayerDataCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedPayerDataRequirement * _Nullable identifier __attribute__((swift_name("identifier")));
@property (readonly) PrimalSharedPayerDataRequirement *name __attribute__((swift_name("name")));
- (instancetype)initWithName:(PrimalSharedPayerDataRequirement *)name identifier:(PrimalSharedPayerDataRequirement * _Nullable)identifier __attribute__((swift_name("init(name:identifier:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPayerData *)doCopyName:(PrimalSharedPayerDataRequirement *)name identifier:(PrimalSharedPayerDataRequirement * _Nullable)identifier __attribute__((swift_name("doCopy(name:identifier:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayerData.Companion")))
@interface PrimalSharedPayerDataCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPayerDataCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayerDataRequirement")))
@interface PrimalSharedPayerDataRequirement : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPayerDataRequirementCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) BOOL mandatory __attribute__((swift_name("mandatory")));
- (instancetype)initWithMandatory:(BOOL)mandatory __attribute__((swift_name("init(mandatory:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPayerDataRequirement *)doCopyMandatory:(BOOL)mandatory __attribute__((swift_name("doCopy(mandatory:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayerDataRequirement.Companion")))
@interface PrimalSharedPayerDataRequirementCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPayerDataRequirementCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetBalanceResponsePayload")))
@interface PrimalSharedGetBalanceResponsePayload : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedGetBalanceResponsePayloadCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t balance __attribute__((swift_name("balance")));
- (instancetype)initWithBalance:(int64_t)balance __attribute__((swift_name("init(balance:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedGetBalanceResponsePayload *)doCopyBalance:(int64_t)balance __attribute__((swift_name("doCopy(balance:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetBalanceResponsePayload.Companion")))
@interface PrimalSharedGetBalanceResponsePayloadCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedGetBalanceResponsePayloadCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetInfoResponsePayload")))
@interface PrimalSharedGetInfoResponsePayload : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedGetInfoResponsePayloadCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *alias __attribute__((swift_name("alias")));
@property (readonly) NSString * _Nullable blockHash __attribute__((swift_name("blockHash")));
@property (readonly) PrimalSharedLong * _Nullable blockHeight __attribute__((swift_name("blockHeight")));
@property (readonly) NSString * _Nullable color __attribute__((swift_name("color")));
@property (readonly) NSArray<NSString *> *methods __attribute__((swift_name("methods")));
@property (readonly) NSString * _Nullable network __attribute__((swift_name("network")));
@property (readonly) NSString * _Nullable pubkey __attribute__((swift_name("pubkey")));
- (instancetype)initWithAlias:(NSString *)alias color:(NSString * _Nullable)color pubkey:(NSString * _Nullable)pubkey network:(NSString * _Nullable)network blockHeight:(PrimalSharedLong * _Nullable)blockHeight blockHash:(NSString * _Nullable)blockHash methods:(NSArray<NSString *> *)methods __attribute__((swift_name("init(alias:color:pubkey:network:blockHeight:blockHash:methods:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedGetInfoResponsePayload *)doCopyAlias:(NSString *)alias color:(NSString * _Nullable)color pubkey:(NSString * _Nullable)pubkey network:(NSString * _Nullable)network blockHeight:(PrimalSharedLong * _Nullable)blockHeight blockHash:(NSString * _Nullable)blockHash methods:(NSArray<NSString *> *)methods __attribute__((swift_name("doCopy(alias:color:pubkey:network:blockHeight:blockHash:methods:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="block_hash")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="block_height")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("GetInfoResponsePayload.Companion")))
@interface PrimalSharedGetInfoResponsePayloadCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedGetInfoResponsePayloadCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ListTransactionsParams")))
@interface PrimalSharedListTransactionsParams : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedListTransactionsParamsCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedLong * _Nullable from __attribute__((swift_name("from")));
@property (readonly) PrimalSharedInt * _Nullable limit __attribute__((swift_name("limit")));
@property (readonly) PrimalSharedInt * _Nullable offset __attribute__((swift_name("offset")));
@property (readonly) NSString * _Nullable type __attribute__((swift_name("type")));
@property (readonly) PrimalSharedBoolean * _Nullable unpaid __attribute__((swift_name("unpaid")));
@property (readonly) PrimalSharedLong * _Nullable until __attribute__((swift_name("until")));
- (instancetype)initWithFrom:(PrimalSharedLong * _Nullable)from until:(PrimalSharedLong * _Nullable)until limit:(PrimalSharedInt * _Nullable)limit offset:(PrimalSharedInt * _Nullable)offset unpaid:(PrimalSharedBoolean * _Nullable)unpaid type:(NSString * _Nullable)type __attribute__((swift_name("init(from:until:limit:offset:unpaid:type:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedListTransactionsParams *)doCopyFrom:(PrimalSharedLong * _Nullable)from until:(PrimalSharedLong * _Nullable)until limit:(PrimalSharedInt * _Nullable)limit offset:(PrimalSharedInt * _Nullable)offset unpaid:(PrimalSharedBoolean * _Nullable)unpaid type:(NSString * _Nullable)type __attribute__((swift_name("doCopy(from:until:limit:offset:unpaid:type:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ListTransactionsParams.Companion")))
@interface PrimalSharedListTransactionsParamsCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedListTransactionsParamsCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ListTransactionsResponsePayload")))
@interface PrimalSharedListTransactionsResponsePayload : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedListTransactionsResponsePayloadCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<PrimalSharedLookupInvoiceResponsePayload *> *transactions __attribute__((swift_name("transactions")));
- (instancetype)initWithTransactions:(NSArray<PrimalSharedLookupInvoiceResponsePayload *> *)transactions __attribute__((swift_name("init(transactions:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedListTransactionsResponsePayload *)doCopyTransactions:(NSArray<PrimalSharedLookupInvoiceResponsePayload *> *)transactions __attribute__((swift_name("doCopy(transactions:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ListTransactionsResponsePayload.Companion")))
@interface PrimalSharedListTransactionsResponsePayloadCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedListTransactionsResponsePayloadCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LookupInvoiceParams")))
@interface PrimalSharedLookupInvoiceParams : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedLookupInvoiceParamsCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString * _Nullable invoice __attribute__((swift_name("invoice")));
@property (readonly) NSString * _Nullable paymentHash __attribute__((swift_name("paymentHash")));
- (instancetype)initWithInvoice:(NSString * _Nullable)invoice paymentHash:(NSString * _Nullable)paymentHash __attribute__((swift_name("init(invoice:paymentHash:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedLookupInvoiceParams *)doCopyInvoice:(NSString * _Nullable)invoice paymentHash:(NSString * _Nullable)paymentHash __attribute__((swift_name("doCopy(invoice:paymentHash:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="payment_hash")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LookupInvoiceParams.Companion")))
@interface PrimalSharedLookupInvoiceParamsCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedLookupInvoiceParamsCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LookupInvoiceResponsePayload")))
@interface PrimalSharedLookupInvoiceResponsePayload : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedLookupInvoiceResponsePayloadCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t amount __attribute__((swift_name("amount")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSString * _Nullable descriptionHash __attribute__((swift_name("descriptionHash")));
@property (readonly) PrimalSharedLong * _Nullable expiresAt __attribute__((swift_name("expiresAt")));
@property (readonly) PrimalSharedLong * _Nullable fees_paid __attribute__((swift_name("fees_paid")));
@property (readonly) NSString * _Nullable invoice __attribute__((swift_name("invoice")));
@property (readonly) NSDictionary<NSString *, NSString *> * _Nullable metadata __attribute__((swift_name("metadata")));
@property (readonly) NSString * _Nullable paymentHash __attribute__((swift_name("paymentHash")));
@property (readonly) NSString * _Nullable preimage __attribute__((swift_name("preimage")));
@property (readonly) PrimalSharedLong * _Nullable settledAt __attribute__((swift_name("settledAt")));
@property (readonly) NSString * _Nullable type __attribute__((swift_name("type")));
- (instancetype)initWithType:(NSString * _Nullable)type invoice:(NSString * _Nullable)invoice descriptionHash:(NSString * _Nullable)descriptionHash description:(NSString * _Nullable)description preimage:(NSString * _Nullable)preimage paymentHash:(NSString * _Nullable)paymentHash amount:(int64_t)amount fees_paid:(PrimalSharedLong * _Nullable)fees_paid createdAt:(int64_t)createdAt expiresAt:(PrimalSharedLong * _Nullable)expiresAt settledAt:(PrimalSharedLong * _Nullable)settledAt metadata:(NSDictionary<NSString *, NSString *> * _Nullable)metadata __attribute__((swift_name("init(type:invoice:descriptionHash:description:preimage:paymentHash:amount:fees_paid:createdAt:expiresAt:settledAt:metadata:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedLookupInvoiceResponsePayload *)doCopyType:(NSString * _Nullable)type invoice:(NSString * _Nullable)invoice descriptionHash:(NSString * _Nullable)descriptionHash description:(NSString * _Nullable)description preimage:(NSString * _Nullable)preimage paymentHash:(NSString * _Nullable)paymentHash amount:(int64_t)amount fees_paid:(PrimalSharedLong * _Nullable)fees_paid createdAt:(int64_t)createdAt expiresAt:(PrimalSharedLong * _Nullable)expiresAt settledAt:(PrimalSharedLong * _Nullable)settledAt metadata:(NSDictionary<NSString *, NSString *> * _Nullable)metadata __attribute__((swift_name("doCopy(type:invoice:descriptionHash:description:preimage:paymentHash:amount:fees_paid:createdAt:expiresAt:settledAt:metadata:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="created_at")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="description_hash")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="expires_at")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="payment_hash")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="settled_at")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LookupInvoiceResponsePayload.Companion")))
@interface PrimalSharedLookupInvoiceResponsePayloadCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedLookupInvoiceResponsePayloadCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MakeInvoiceParams")))
@interface PrimalSharedMakeInvoiceParams : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedMakeInvoiceParamsCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t amount __attribute__((swift_name("amount")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSString * _Nullable descriptionHash __attribute__((swift_name("descriptionHash")));
@property (readonly) PrimalSharedLong * _Nullable expiry __attribute__((swift_name("expiry")));
- (instancetype)initWithAmount:(int64_t)amount description:(NSString * _Nullable)description descriptionHash:(NSString * _Nullable)descriptionHash expiry:(PrimalSharedLong * _Nullable)expiry __attribute__((swift_name("init(amount:description:descriptionHash:expiry:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedMakeInvoiceParams *)doCopyAmount:(int64_t)amount description:(NSString * _Nullable)description descriptionHash:(NSString * _Nullable)descriptionHash expiry:(PrimalSharedLong * _Nullable)expiry __attribute__((swift_name("doCopy(amount:description:descriptionHash:expiry:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="description_hash")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MakeInvoiceParams.Companion")))
@interface PrimalSharedMakeInvoiceParamsCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedMakeInvoiceParamsCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MakeInvoiceResponsePayload")))
@interface PrimalSharedMakeInvoiceResponsePayload : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedMakeInvoiceResponsePayloadCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t amount __attribute__((swift_name("amount")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSString * _Nullable descriptionHash __attribute__((swift_name("descriptionHash")));
@property (readonly) PrimalSharedLong * _Nullable expiresAt __attribute__((swift_name("expiresAt")));
@property (readonly) PrimalSharedLong * _Nullable feesPaid __attribute__((swift_name("feesPaid")));
@property (readonly) NSString * _Nullable invoice __attribute__((swift_name("invoice")));
@property (readonly) NSDictionary<NSString *, NSString *> * _Nullable metadata __attribute__((swift_name("metadata")));
@property (readonly) NSString *paymentHash __attribute__((swift_name("paymentHash")));
@property (readonly) NSString * _Nullable preimage __attribute__((swift_name("preimage")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
- (instancetype)initWithType:(NSString *)type invoice:(NSString * _Nullable)invoice description:(NSString * _Nullable)description descriptionHash:(NSString * _Nullable)descriptionHash preimage:(NSString * _Nullable)preimage paymentHash:(NSString *)paymentHash amount:(int64_t)amount feesPaid:(PrimalSharedLong * _Nullable)feesPaid createdAt:(int64_t)createdAt expiresAt:(PrimalSharedLong * _Nullable)expiresAt metadata:(NSDictionary<NSString *, NSString *> * _Nullable)metadata __attribute__((swift_name("init(type:invoice:description:descriptionHash:preimage:paymentHash:amount:feesPaid:createdAt:expiresAt:metadata:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedMakeInvoiceResponsePayload *)doCopyType:(NSString *)type invoice:(NSString * _Nullable)invoice description:(NSString * _Nullable)description descriptionHash:(NSString * _Nullable)descriptionHash preimage:(NSString * _Nullable)preimage paymentHash:(NSString *)paymentHash amount:(int64_t)amount feesPaid:(PrimalSharedLong * _Nullable)feesPaid createdAt:(int64_t)createdAt expiresAt:(PrimalSharedLong * _Nullable)expiresAt metadata:(NSDictionary<NSString *, NSString *> * _Nullable)metadata __attribute__((swift_name("doCopy(type:invoice:description:descriptionHash:preimage:paymentHash:amount:feesPaid:createdAt:expiresAt:metadata:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="created_at")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="description_hash")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="expires_at")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="fees_paid")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="payment_hash")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MakeInvoiceResponsePayload.Companion")))
@interface PrimalSharedMakeInvoiceResponsePayloadCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedMakeInvoiceResponsePayloadCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcError")))
@interface PrimalSharedNwcError : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedNwcErrorCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *code __attribute__((swift_name("code")));
@property (readonly) NSString *message __attribute__((swift_name("message")));
- (instancetype)initWithCode:(NSString *)code message:(NSString *)message __attribute__((swift_name("init(code:message:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNwcError *)doCopyCode:(NSString *)code message:(NSString *)message __attribute__((swift_name("doCopy(code:message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcError.Companion")))
@interface PrimalSharedNwcErrorCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNwcErrorCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) NSString *INSUFFICIENT_BALANCE __attribute__((swift_name("INSUFFICIENT_BALANCE")));
@property (readonly) NSString *INTERNAL __attribute__((swift_name("INTERNAL")));
@property (readonly) NSString *NOT_IMPLEMENTED __attribute__((swift_name("NOT_IMPLEMENTED")));
@property (readonly) NSString *OTHER __attribute__((swift_name("OTHER")));
@property (readonly) NSString *QUOTA_EXCEEDED __attribute__((swift_name("QUOTA_EXCEEDED")));
@property (readonly) NSString *RATE_LIMITED __attribute__((swift_name("RATE_LIMITED")));
@property (readonly) NSString *RESTRICTED __attribute__((swift_name("RESTRICTED")));
@property (readonly) NSString *UNAUTHORIZED __attribute__((swift_name("UNAUTHORIZED")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("NwcMethod")))
@interface PrimalSharedNwcMethod : PrimalSharedBase
@property (readonly) NSString *value __attribute__((swift_name("value")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.GetBalance")))
@interface PrimalSharedNwcMethodGetBalance : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodGetBalance *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)getBalance __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.GetInfo")))
@interface PrimalSharedNwcMethodGetInfo : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodGetInfo *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)getInfo __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.ListTransactions")))
@interface PrimalSharedNwcMethodListTransactions : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodListTransactions *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)listTransactions __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.LookupInvoice")))
@interface PrimalSharedNwcMethodLookupInvoice : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodLookupInvoice *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)lookupInvoice __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.MakeInvoice")))
@interface PrimalSharedNwcMethodMakeInvoice : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodMakeInvoice *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)makeInvoice __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.MultiPayInvoice")))
@interface PrimalSharedNwcMethodMultiPayInvoice : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodMultiPayInvoice *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)multiPayInvoice __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.MultiPayKeysend")))
@interface PrimalSharedNwcMethodMultiPayKeysend : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodMultiPayKeysend *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)multiPayKeysend __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.PayInvoice")))
@interface PrimalSharedNwcMethodPayInvoice : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodPayInvoice *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)payInvoice __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.PayKeysend")))
@interface PrimalSharedNwcMethodPayKeysend : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodPayKeysend *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)payKeysend __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.PaymentReceived")))
@interface PrimalSharedNwcMethodPaymentReceived : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodPaymentReceived *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)paymentReceived __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcMethod.PaymentSent")))
@interface PrimalSharedNwcMethodPaymentSent : PrimalSharedNwcMethod
@property (class, readonly, getter=shared) PrimalSharedNwcMethodPaymentSent *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)paymentSent __attribute__((swift_name("init()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcResponseContent")))
@interface PrimalSharedNwcResponseContent<T> : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedNwcResponseContentCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedNwcError * _Nullable error __attribute__((swift_name("error")));
@property (readonly) T _Nullable result __attribute__((swift_name("result")));
@property (readonly) NSString *resultType __attribute__((swift_name("resultType")));
- (instancetype)initWithResultType:(NSString *)resultType error:(PrimalSharedNwcError * _Nullable)error result:(T _Nullable)result __attribute__((swift_name("init(resultType:error:result:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNwcResponseContent<T> *)doCopyResultType:(NSString *)resultType error:(PrimalSharedNwcError * _Nullable)error result:(T _Nullable)result __attribute__((swift_name("doCopy(resultType:error:result:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="result_type")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NwcResponseContentCompanion")))
@interface PrimalSharedNwcResponseContentCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNwcResponseContentCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializerTypeParamsSerializers:(PrimalSharedKotlinArray<id<PrimalSharedKotlinx_serialization_coreKSerializer>> *)typeParamsSerializers __attribute__((swift_name("serializer(typeParamsSerializers:)")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializerTypeSerial0:(id<PrimalSharedKotlinx_serialization_coreKSerializer>)typeSerial0 __attribute__((swift_name("serializer(typeSerial0:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayInvoiceParams")))
@interface PrimalSharedPayInvoiceParams : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPayInvoiceParamsCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedLong * _Nullable amount __attribute__((swift_name("amount")));
@property (readonly) NSString *invoice __attribute__((swift_name("invoice")));
- (instancetype)initWithInvoice:(NSString *)invoice amount:(PrimalSharedLong * _Nullable)amount __attribute__((swift_name("init(invoice:amount:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPayInvoiceParams *)doCopyInvoice:(NSString *)invoice amount:(PrimalSharedLong * _Nullable)amount __attribute__((swift_name("doCopy(invoice:amount:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayInvoiceParams.Companion")))
@interface PrimalSharedPayInvoiceParamsCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPayInvoiceParamsCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayInvoiceResponsePayload")))
@interface PrimalSharedPayInvoiceResponsePayload : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPayInvoiceResponsePayloadCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedLong * _Nullable feesPaid __attribute__((swift_name("feesPaid")));
@property (readonly) NSString * _Nullable preimage __attribute__((swift_name("preimage")));
- (instancetype)initWithPreimage:(NSString * _Nullable)preimage feesPaid:(PrimalSharedLong * _Nullable)feesPaid __attribute__((swift_name("init(preimage:feesPaid:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPayInvoiceResponsePayload *)doCopyPreimage:(NSString * _Nullable)preimage feesPaid:(PrimalSharedLong * _Nullable)feesPaid __attribute__((swift_name("doCopy(preimage:feesPaid:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="fees_paid")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayInvoiceResponsePayload.Companion")))
@interface PrimalSharedPayInvoiceResponsePayloadCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPayInvoiceResponsePayloadCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayKeysendParams")))
@interface PrimalSharedPayKeysendParams : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPayKeysendParamsCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t amount __attribute__((swift_name("amount")));
@property (readonly) NSString * _Nullable preimage __attribute__((swift_name("preimage")));
@property (readonly) NSString *pubkey __attribute__((swift_name("pubkey")));
@property (readonly) NSArray<PrimalSharedTlvRecord *> * _Nullable tlvRecords __attribute__((swift_name("tlvRecords")));
- (instancetype)initWithPubkey:(NSString *)pubkey amount:(int64_t)amount preimage:(NSString * _Nullable)preimage tlvRecords:(NSArray<PrimalSharedTlvRecord *> * _Nullable)tlvRecords __attribute__((swift_name("init(pubkey:amount:preimage:tlvRecords:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPayKeysendParams *)doCopyPubkey:(NSString *)pubkey amount:(int64_t)amount preimage:(NSString * _Nullable)preimage tlvRecords:(NSArray<PrimalSharedTlvRecord *> * _Nullable)tlvRecords __attribute__((swift_name("doCopy(pubkey:amount:preimage:tlvRecords:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="tlv_records")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayKeysendParams.Companion")))
@interface PrimalSharedPayKeysendParamsCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPayKeysendParamsCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayKeysendResponsePayload")))
@interface PrimalSharedPayKeysendResponsePayload : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPayKeysendResponsePayloadCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedLong * _Nullable feesPaid __attribute__((swift_name("feesPaid")));
@property (readonly) NSString * _Nullable preimage __attribute__((swift_name("preimage")));
- (instancetype)initWithPreimage:(NSString * _Nullable)preimage feesPaid:(PrimalSharedLong * _Nullable)feesPaid __attribute__((swift_name("init(preimage:feesPaid:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPayKeysendResponsePayload *)doCopyPreimage:(NSString * _Nullable)preimage feesPaid:(PrimalSharedLong * _Nullable)feesPaid __attribute__((swift_name("doCopy(preimage:feesPaid:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="fees_paid")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PayKeysendResponsePayload.Companion")))
@interface PrimalSharedPayKeysendResponsePayloadCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPayKeysendResponsePayloadCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("TlvRecord")))
@interface PrimalSharedTlvRecord : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedTlvRecordCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t type __attribute__((swift_name("type")));
@property (readonly) NSString *value __attribute__((swift_name("value")));
- (instancetype)initWithType:(int64_t)type value:(NSString *)value __attribute__((swift_name("init(type:value:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedTlvRecord *)doCopyType:(int64_t)type value:(NSString *)value __attribute__((swift_name("doCopy(type:value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("TlvRecord.Companion")))
@interface PrimalSharedTlvRecordCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedTlvRecordCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("PrimalApiClient")))
@protocol PrimalSharedPrimalApiClient
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)closeSubscriptionSubscriptionId:(NSString *)subscriptionId completionHandler:(void (^)(PrimalSharedBoolean * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("closeSubscription(subscriptionId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)queryMessage:(PrimalSharedPrimalCacheFilter *)message completionHandler:(void (^)(PrimalSharedPrimalQueryResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("query(message:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)subscribeSubscriptionId:(NSString *)subscriptionId message:(PrimalSharedPrimalCacheFilter *)message completionHandler:(void (^)(id<PrimalSharedKotlinx_coroutines_coreFlow> _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("subscribe(subscriptionId:message:completionHandler:)")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreStateFlow> connectionStatus __attribute__((swift_name("connectionStatus")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalCacheFilter")))
@interface PrimalSharedPrimalCacheFilter : PrimalSharedBase
@property (readonly) NSString * _Nullable optionsJson __attribute__((swift_name("optionsJson")));
@property (readonly) NSString * _Nullable primalVerb __attribute__((swift_name("primalVerb")));
- (instancetype)initWithPrimalVerb:(NSString * _Nullable)primalVerb optionsJson:(NSString * _Nullable)optionsJson __attribute__((swift_name("init(primalVerb:optionsJson:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalCacheFilter *)doCopyPrimalVerb:(NSString * _Nullable)primalVerb optionsJson:(NSString * _Nullable)optionsJson __attribute__((swift_name("doCopy(primalVerb:optionsJson:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)toPrimalJsonObject __attribute__((swift_name("toPrimalJsonObject()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalQueryResult")))
@interface PrimalSharedPrimalQueryResult : PrimalSharedBase
@property (readonly) NSArray<PrimalSharedNostrEvent *> *nostrEvents __attribute__((swift_name("nostrEvents")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *primalEvents __attribute__((swift_name("primalEvents")));
@property (readonly) PrimalSharedNostrIncomingMessage *terminationMessage __attribute__((swift_name("terminationMessage")));
- (instancetype)initWithTerminationMessage:(PrimalSharedNostrIncomingMessage *)terminationMessage nostrEvents:(NSArray<PrimalSharedNostrEvent *> *)nostrEvents primalEvents:(NSArray<PrimalSharedPrimalEvent *> *)primalEvents __attribute__((swift_name("init(terminationMessage:nostrEvents:primalEvents:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalQueryResult *)doCopyTerminationMessage:(PrimalSharedNostrIncomingMessage *)terminationMessage nostrEvents:(NSArray<PrimalSharedNostrEvent *> *)nostrEvents primalEvents:(NSArray<PrimalSharedPrimalEvent *> *)primalEvents __attribute__((swift_name("doCopy(terminationMessage:nostrEvents:primalEvents:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSArray<PrimalSharedNostrEvent *> *)filterNostrEventsKind:(PrimalSharedNostrEventKind *)kind __attribute__((swift_name("filterNostrEvents(kind:)")));
- (NSArray<PrimalSharedPrimalEvent *> *)filterPrimalEventsKind:(PrimalSharedNostrEventKind *)kind __attribute__((swift_name("filterPrimalEvents(kind:)")));
- (PrimalSharedNostrEvent * _Nullable)findNostrEventKind:(PrimalSharedNostrEventKind *)kind __attribute__((swift_name("findNostrEvent(kind:)")));
- (PrimalSharedPrimalEvent * _Nullable)findPrimalEventKind:(PrimalSharedNostrEventKind *)kind __attribute__((swift_name("findPrimalEvent(kind:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalServerConnectionStatus")))
@interface PrimalSharedPrimalServerConnectionStatus : PrimalSharedBase
@property (readonly) BOOL connected __attribute__((swift_name("connected")));
@property (readonly) PrimalSharedPrimalServerType *serverType __attribute__((swift_name("serverType")));
@property (readonly) NSString *url __attribute__((swift_name("url")));
- (instancetype)initWithServerType:(PrimalSharedPrimalServerType *)serverType url:(NSString *)url connected:(BOOL)connected __attribute__((swift_name("init(serverType:url:connected:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalServerConnectionStatus *)doCopyServerType:(PrimalSharedPrimalServerType *)serverType url:(NSString *)url connected:(BOOL)connected __attribute__((swift_name("doCopy(serverType:url:connected:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalSocketSubscription")))
@interface PrimalSharedPrimalSocketSubscription<T> : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPrimalSocketSubscriptionCompanion *companion __attribute__((swift_name("companion")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)unsubscribeWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("unsubscribe(completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalSocketSubscriptionCompanion")))
@interface PrimalSharedPrimalSocketSubscriptionCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPrimalSocketSubscriptionCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedPrimalSocketSubscription<id> *)launchScope:(id<PrimalSharedKotlinx_coroutines_coreCoroutineScope>)scope primalApiClient:(id<PrimalSharedPrimalApiClient>)primalApiClient cacheFilter:(PrimalSharedPrimalCacheFilter *)cacheFilter transformer:(id _Nullable (^)(PrimalSharedNostrIncomingMessageEventMessage *))transformer onEvent:(id<PrimalSharedKotlinSuspendFunction1>)onEvent __attribute__((swift_name("launch(scope:primalApiClient:cacheFilter:transformer:onEvent:)")));
@end

__attribute__((swift_name("NostrIncomingMessage")))
@interface PrimalSharedNostrIncomingMessage : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessage.AuthMessage")))
@interface PrimalSharedNostrIncomingMessageAuthMessage : PrimalSharedNostrIncomingMessage
@property (readonly) NSString *challenge __attribute__((swift_name("challenge")));
- (instancetype)initWithChallenge:(NSString *)challenge __attribute__((swift_name("init(challenge:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrIncomingMessageAuthMessage *)doCopyChallenge:(NSString *)challenge __attribute__((swift_name("doCopy(challenge:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessage.CountMessage")))
@interface PrimalSharedNostrIncomingMessageCountMessage : PrimalSharedNostrIncomingMessage
@property (readonly) int32_t count __attribute__((swift_name("count")));
@property (readonly) NSString *subscriptionId __attribute__((swift_name("subscriptionId")));
- (instancetype)initWithSubscriptionId:(NSString *)subscriptionId count:(int32_t)count __attribute__((swift_name("init(subscriptionId:count:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrIncomingMessageCountMessage *)doCopySubscriptionId:(NSString *)subscriptionId count:(int32_t)count __attribute__((swift_name("doCopy(subscriptionId:count:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessage.EoseMessage")))
@interface PrimalSharedNostrIncomingMessageEoseMessage : PrimalSharedNostrIncomingMessage
@property (readonly) NSString *subscriptionId __attribute__((swift_name("subscriptionId")));
- (instancetype)initWithSubscriptionId:(NSString *)subscriptionId __attribute__((swift_name("init(subscriptionId:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrIncomingMessageEoseMessage *)doCopySubscriptionId:(NSString *)subscriptionId __attribute__((swift_name("doCopy(subscriptionId:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessage.EventMessage")))
@interface PrimalSharedNostrIncomingMessageEventMessage : PrimalSharedNostrIncomingMessage
@property (readonly) PrimalSharedNostrEvent * _Nullable nostrEvent __attribute__((swift_name("nostrEvent")));
@property (readonly) PrimalSharedPrimalEvent * _Nullable primalEvent __attribute__((swift_name("primalEvent")));
@property (readonly) NSString *subscriptionId __attribute__((swift_name("subscriptionId")));
- (instancetype)initWithSubscriptionId:(NSString *)subscriptionId nostrEvent:(PrimalSharedNostrEvent * _Nullable)nostrEvent primalEvent:(PrimalSharedPrimalEvent * _Nullable)primalEvent __attribute__((swift_name("init(subscriptionId:nostrEvent:primalEvent:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrIncomingMessageEventMessage *)doCopySubscriptionId:(NSString *)subscriptionId nostrEvent:(PrimalSharedNostrEvent * _Nullable)nostrEvent primalEvent:(PrimalSharedPrimalEvent * _Nullable)primalEvent __attribute__((swift_name("doCopy(subscriptionId:nostrEvent:primalEvent:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessage.EventsMessage")))
@interface PrimalSharedNostrIncomingMessageEventsMessage : PrimalSharedNostrIncomingMessage
@property (readonly) NSArray<PrimalSharedNostrEvent *> *nostrEvents __attribute__((swift_name("nostrEvents")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *primalEvents __attribute__((swift_name("primalEvents")));
@property (readonly) NSString *subscriptionId __attribute__((swift_name("subscriptionId")));
- (instancetype)initWithSubscriptionId:(NSString *)subscriptionId nostrEvents:(NSArray<PrimalSharedNostrEvent *> *)nostrEvents primalEvents:(NSArray<PrimalSharedPrimalEvent *> *)primalEvents __attribute__((swift_name("init(subscriptionId:nostrEvents:primalEvents:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrIncomingMessageEventsMessage *)doCopySubscriptionId:(NSString *)subscriptionId nostrEvents:(NSArray<PrimalSharedNostrEvent *> *)nostrEvents primalEvents:(NSArray<PrimalSharedPrimalEvent *> *)primalEvents __attribute__((swift_name("doCopy(subscriptionId:nostrEvents:primalEvents:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessage.NoticeMessage")))
@interface PrimalSharedNostrIncomingMessageNoticeMessage : PrimalSharedNostrIncomingMessage
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
@property (readonly) NSString * _Nullable subscriptionId __attribute__((swift_name("subscriptionId")));
- (instancetype)initWithSubscriptionId:(NSString * _Nullable)subscriptionId message:(NSString * _Nullable)message __attribute__((swift_name("init(subscriptionId:message:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrIncomingMessageNoticeMessage *)doCopySubscriptionId:(NSString * _Nullable)subscriptionId message:(NSString * _Nullable)message __attribute__((swift_name("doCopy(subscriptionId:message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessage.OkMessage")))
@interface PrimalSharedNostrIncomingMessageOkMessage : PrimalSharedNostrIncomingMessage
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
@property (readonly) BOOL success __attribute__((swift_name("success")));
- (instancetype)initWithEventId:(NSString *)eventId success:(BOOL)success message:(NSString * _Nullable)message __attribute__((swift_name("init(eventId:success:message:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrIncomingMessageOkMessage *)doCopyEventId:(NSString *)eventId success:(BOOL)success message:(NSString * _Nullable)message __attribute__((swift_name("doCopy(eventId:success:message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("NostrSocketClient")))
@protocol PrimalSharedNostrSocketClient
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)closeWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("close(completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)ensureSocketConnectionOrThrowWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("ensureSocketConnectionOrThrow(completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)sendAUTHSignedEvent:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)signedEvent completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("sendAUTH(signedEvent:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)sendCLOSESubscriptionId:(NSString *)subscriptionId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("sendCLOSE(subscriptionId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)sendCOUNTData:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)data completionHandler:(void (^)(NSString * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("sendCOUNT(data:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)sendEVENTSignedEvent:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)signedEvent completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("sendEVENT(signedEvent:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)sendREQSubscriptionId:(NSString *)subscriptionId data:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)data completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("sendREQ(subscriptionId:data:completionHandler:)")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreSharedFlow> incomingMessages __attribute__((swift_name("incomingMessages")));
@property (readonly) NSString *socketUrl __attribute__((swift_name("socketUrl")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrSocketClientFactory")))
@interface PrimalSharedNostrSocketClientFactory : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrSocketClientFactory *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)nostrSocketClientFactory __attribute__((swift_name("init()")));
- (id<PrimalSharedNostrSocketClient>)createWssUrl:(NSString *)wssUrl incomingCompressionEnabled:(BOOL)incomingCompressionEnabled onSocketConnectionOpened:(void (^ _Nullable)(NSString *))onSocketConnectionOpened onSocketConnectionClosed:(void (^ _Nullable)(NSString *, PrimalSharedKotlinThrowable * _Nullable))onSocketConnectionClosed __attribute__((swift_name("create(wssUrl:incomingCompressionEnabled:onSocketConnectionOpened:onSocketConnectionClosed:)")));
- (id<PrimalSharedNostrSocketClient>)createWssUrl:(NSString *)wssUrl httpClient:(PrimalSharedKtor_client_coreHttpClient *)httpClient incomingCompressionEnabled:(BOOL)incomingCompressionEnabled onSocketConnectionOpened:(void (^ _Nullable)(NSString *))onSocketConnectionOpened onSocketConnectionClosed:(void (^ _Nullable)(NSString *, PrimalSharedKotlinThrowable * _Nullable))onSocketConnectionClosed __attribute__((swift_name("create(wssUrl:httpClient:incomingCompressionEnabled:onSocketConnectionOpened:onSocketConnectionClosed:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrNoticeException")))
@interface PrimalSharedNostrNoticeException : PrimalSharedKotlinRuntimeException
@property (readonly) NSString * _Nullable reason __attribute__((swift_name("reason")));
@property (readonly) NSString * _Nullable subscriptionId __attribute__((swift_name("subscriptionId")));
- (instancetype)initWithReason:(NSString * _Nullable)reason subscriptionId:(NSString * _Nullable)subscriptionId __attribute__((swift_name("init(reason:subscriptionId:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BookmarkType")))
@interface PrimalSharedBookmarkType : PrimalSharedKotlinEnum<PrimalSharedBookmarkType *>
@property (class, readonly) PrimalSharedBookmarkType *note __attribute__((swift_name("note")));
@property (class, readonly) PrimalSharedBookmarkType *article __attribute__((swift_name("article")));
@property (class, readonly) NSArray<PrimalSharedBookmarkType *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedBookmarkType *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PublicBookmark")))
@interface PrimalSharedPublicBookmark : PrimalSharedBase
@property (readonly) PrimalSharedBookmarkType *bookmarkType __attribute__((swift_name("bookmarkType")));
@property (readonly) NSString *ownerId __attribute__((swift_name("ownerId")));
@property (readonly) NSString *tagType __attribute__((swift_name("tagType")));
@property (readonly) NSString *tagValue __attribute__((swift_name("tagValue")));
- (instancetype)initWithTagValue:(NSString *)tagValue tagType:(NSString *)tagType bookmarkType:(PrimalSharedBookmarkType *)bookmarkType ownerId:(NSString *)ownerId __attribute__((swift_name("init(tagValue:tagType:bookmarkType:ownerId:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPublicBookmark *)doCopyTagValue:(NSString *)tagValue tagType:(NSString *)tagType bookmarkType:(PrimalSharedBookmarkType *)bookmarkType ownerId:(NSString *)ownerId __attribute__((swift_name("doCopy(tagValue:tagType:bookmarkType:ownerId:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("PublicBookmarksRepository")))
@protocol PrimalSharedPublicBookmarksRepository
@required

/**
 * @note This method converts instances of PublicBookmarksNotFoundException, NostrPublishException, SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)addToBookmarksUserId:(NSString *)userId bookmarkType:(PrimalSharedBookmarkType *)bookmarkType tagValue:(NSString *)tagValue forceUpdate:(BOOL)forceUpdate completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("addToBookmarks(userId:bookmarkType:tagValue:forceUpdate:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchAndPersistBookmarksUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchAndPersistBookmarks(userId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)isBookmarkedTagValue:(NSString *)tagValue completionHandler:(void (^)(PrimalSharedBoolean * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("isBookmarked(tagValue:completionHandler:)")));

/**
 * @note This method converts instances of PublicBookmarksNotFoundException, NostrPublishException, SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)removeFromBookmarksUserId:(NSString *)userId bookmarkType:(PrimalSharedBookmarkType *)bookmarkType tagValue:(NSString *)tagValue forceUpdate:(BOOL)forceUpdate completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("removeFromBookmarks(userId:bookmarkType:tagValue:forceUpdate:completionHandler:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("TagBookmark")))
@interface PrimalSharedTagBookmark : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedTagBookmarkCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *type __attribute__((swift_name("type")));
@property (readonly) NSString *value __attribute__((swift_name("value")));
- (instancetype)initWithType:(NSString *)type value:(NSString *)value __attribute__((swift_name("init(type:value:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedTagBookmark *)doCopyType:(NSString *)type value:(NSString *)value __attribute__((swift_name("doCopy(type:value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("TagBookmark.Companion")))
@interface PrimalSharedTagBookmarkCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedTagBookmarkCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentPrimalPaging")))
@interface PrimalSharedContentPrimalPaging : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedContentPrimalPagingCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<NSString *> *elements __attribute__((swift_name("elements")));
@property (readonly) NSString *orderBy __attribute__((swift_name("orderBy")));
@property (readonly) PrimalSharedLong * _Nullable sinceId __attribute__((swift_name("sinceId")));
@property (readonly) PrimalSharedLong * _Nullable untilId __attribute__((swift_name("untilId")));
- (instancetype)initWithOrderBy:(NSString *)orderBy sinceId:(PrimalSharedLong * _Nullable)sinceId untilId:(PrimalSharedLong * _Nullable)untilId elements:(NSArray<NSString *> *)elements __attribute__((swift_name("init(orderBy:sinceId:untilId:elements:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedContentPrimalPaging *)doCopyOrderBy:(NSString *)orderBy sinceId:(PrimalSharedLong * _Nullable)sinceId untilId:(PrimalSharedLong * _Nullable)untilId elements:(NSArray<NSString *> *)elements __attribute__((swift_name("doCopy(orderBy:sinceId:untilId:elements:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="elements")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="order_by")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="since")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="until")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentPrimalPaging.Companion")))
@interface PrimalSharedContentPrimalPagingCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedContentPrimalPagingCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalEvent")))
@interface PrimalSharedPrimalEvent : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPrimalEventCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) PrimalSharedLong * _Nullable createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString * _Nullable id __attribute__((swift_name("id")));
@property (readonly) int32_t kind __attribute__((swift_name("kind")));
@property (readonly) NSString * _Nullable pubKey __attribute__((swift_name("pubKey")));
@property (readonly) NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *tags __attribute__((swift_name("tags")));
- (instancetype)initWithKind:(int32_t)kind id:(NSString * _Nullable)id pubKey:(NSString * _Nullable)pubKey createdAt:(PrimalSharedLong * _Nullable)createdAt tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags content:(NSString *)content __attribute__((swift_name("init(kind:id:pubKey:createdAt:tags:content:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalEvent *)doCopyKind:(int32_t)kind id:(NSString * _Nullable)id pubKey:(NSString * _Nullable)pubKey createdAt:(PrimalSharedLong * _Nullable)createdAt tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags content:(NSString *)content __attribute__((swift_name("doCopy(kind:id:pubKey:createdAt:tags:content:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="created_at")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="pubkey")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalEvent.Companion")))
@interface PrimalSharedPrimalEventCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPrimalEventCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalScope")))
@interface PrimalSharedPrimalScope : PrimalSharedKotlinEnum<PrimalSharedPrimalScope *>
@property (class, readonly) PrimalSharedPrimalScope *follows __attribute__((swift_name("follows")));
@property (class, readonly) PrimalSharedPrimalScope *tribe __attribute__((swift_name("tribe")));
@property (class, readonly) PrimalSharedPrimalScope *network __attribute__((swift_name("network")));
@property (class, readonly) PrimalSharedPrimalScope *global __attribute__((swift_name("global")));
@property (class, readonly) NSArray<PrimalSharedPrimalScope *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedPrimalScope *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalTimeframe")))
@interface PrimalSharedPrimalTimeframe : PrimalSharedKotlinEnum<PrimalSharedPrimalTimeframe *>
@property (class, readonly) PrimalSharedPrimalTimeframe *trending __attribute__((swift_name("trending")));
@property (class, readonly) PrimalSharedPrimalTimeframe *zapped __attribute__((swift_name("zapped")));
@property (class, readonly) PrimalSharedPrimalTimeframe *popular __attribute__((swift_name("popular")));
@property (class, readonly) PrimalSharedPrimalTimeframe *latest __attribute__((swift_name("latest")));
@property (class, readonly) NSArray<PrimalSharedPrimalTimeframe *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedPrimalTimeframe *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("UserProfileSearchItem")))
@interface PrimalSharedUserProfileSearchItem : PrimalSharedBase
@property (readonly) PrimalSharedInt * _Nullable followersCount __attribute__((swift_name("followersCount")));
@property (readonly) PrimalSharedProfileData *metadata __attribute__((swift_name("metadata")));
@property (readonly) PrimalSharedFloat * _Nullable score __attribute__((swift_name("score")));
- (instancetype)initWithMetadata:(PrimalSharedProfileData *)metadata score:(PrimalSharedFloat * _Nullable)score followersCount:(PrimalSharedInt * _Nullable)followersCount __attribute__((swift_name("init(metadata:score:followersCount:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedUserProfileSearchItem *)doCopyMetadata:(PrimalSharedProfileData *)metadata score:(PrimalSharedFloat * _Nullable)score followersCount:(PrimalSharedInt * _Nullable)followersCount __attribute__((swift_name("doCopy(metadata:score:followersCount:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NetworkException")))
@interface PrimalSharedNetworkException : PrimalSharedKotlinRuntimeException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((swift_name("EventInteractionRepository")))
@protocol PrimalSharedEventInteractionRepository
@required

/**
 * @note This method converts instances of SignatureException, NostrPublishException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)deleteEventUserId:(NSString *)userId eventIdentifier:(NSString *)eventIdentifier eventKind:(PrimalSharedNostrEventKind *)eventKind content:(NSString *)content relayHint:(NSString * _Nullable)relayHint completionHandler:(void (^)(PrimalSharedPrimalPublishResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("deleteEvent(userId:eventIdentifier:eventKind:content:relayHint:completionHandler:)")));

/**
 * @note This method converts instances of SignatureException, NostrPublishException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)likeEventUserId:(NSString *)userId eventId:(NSString *)eventId eventAuthorId:(NSString *)eventAuthorId optionalTags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)optionalTags completionHandler:(void (^)(PrimalSharedPrimalPublishResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("likeEvent(userId:eventId:eventAuthorId:optionalTags:completionHandler:)")));

/**
 * @note This method converts instances of SignatureException, NostrPublishException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)repostEventUserId:(NSString *)userId eventId:(NSString *)eventId eventKind:(int32_t)eventKind eventAuthorId:(NSString *)eventAuthorId eventRawNostrEvent:(NSString *)eventRawNostrEvent optionalTags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)optionalTags completionHandler:(void (^)(PrimalSharedPrimalPublishResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("repostEvent(userId:eventId:eventKind:eventAuthorId:eventRawNostrEvent:optionalTags:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)zapEventUserId:(NSString *)userId amountInSats:(uint64_t)amountInSats comment:(NSString *)comment target:(PrimalSharedZapTarget *)target zapRequestEvent:(PrimalSharedNostrEvent *)zapRequestEvent completionHandler:(void (^)(PrimalSharedZapResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("zapEvent(userId:amountInSats:comment:target:zapRequestEvent:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventRelayHints")))
@interface PrimalSharedEventRelayHints : PrimalSharedBase
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) NSArray<NSString *> *relays __attribute__((swift_name("relays")));
- (instancetype)initWithEventId:(NSString *)eventId relays:(NSArray<NSString *> *)relays __attribute__((swift_name("init(eventId:relays:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedEventRelayHints *)doCopyEventId:(NSString *)eventId relays:(NSArray<NSString *> *)relays __attribute__((swift_name("doCopy(eventId:relays:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("EventRelayHintsRepository")))
@protocol PrimalSharedEventRelayHintsRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findRelaysByIdsEventIds:(NSArray<NSString *> *)eventIds completionHandler:(void (^)(NSArray<PrimalSharedEventRelayHints *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("findRelaysByIds(eventIds:completionHandler:)")));
@end

__attribute__((swift_name("EventRepository")))
@protocol PrimalSharedEventRepository
@required

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchEventActionsEventId:(NSString *)eventId kind:(int32_t)kind completionHandler:(void (^)(NSArray<PrimalSharedNostrEventAction *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchEventActions(eventId:kind:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchEventZapsUserId:(NSString *)userId eventId:(NSString *)eventId limit:(int32_t)limit completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchEventZaps(userId:eventId:limit:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeEventStatsEventIds:(NSArray<NSString *> *)eventIds __attribute__((swift_name("observeEventStats(eventIds:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeUserEventStatusEventIds:(NSArray<NSString *> *)eventIds userId:(NSString *)userId __attribute__((swift_name("observeUserEventStatus(eventIds:userId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)pagedEventZapsUserId:(NSString *)userId eventId:(NSString *)eventId articleATag:(NSString * _Nullable)articleATag __attribute__((swift_name("pagedEventZaps(userId:eventId:articleATag:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventZap")))
@interface PrimalSharedEventZap : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedEventZapCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) uint64_t amountInSats __attribute__((swift_name("amountInSats")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
@property (readonly) int64_t zappedAt __attribute__((swift_name("zappedAt")));
@property (readonly) PrimalSharedCdnImage * _Nullable zapperAvatarCdnImage __attribute__((swift_name("zapperAvatarCdnImage")));
@property (readonly) NSString *zapperHandle __attribute__((swift_name("zapperHandle")));
@property (readonly) NSString *zapperId __attribute__((swift_name("zapperId")));
@property (readonly) NSString * _Nullable zapperInternetIdentifier __attribute__((swift_name("zapperInternetIdentifier")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable zapperLegendProfile __attribute__((swift_name("zapperLegendProfile")));
@property (readonly) NSString *zapperName __attribute__((swift_name("zapperName")));
- (instancetype)initWithId:(NSString *)id zapperId:(NSString *)zapperId zapperName:(NSString *)zapperName zapperHandle:(NSString *)zapperHandle zappedAt:(int64_t)zappedAt message:(NSString * _Nullable)message amountInSats:(uint64_t)amountInSats zapperInternetIdentifier:(NSString * _Nullable)zapperInternetIdentifier zapperAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)zapperAvatarCdnImage zapperLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)zapperLegendProfile __attribute__((swift_name("init(id:zapperId:zapperName:zapperHandle:zappedAt:message:amountInSats:zapperInternetIdentifier:zapperAvatarCdnImage:zapperLegendProfile:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedEventZap *)doCopyId:(NSString *)id zapperId:(NSString *)zapperId zapperName:(NSString *)zapperName zapperHandle:(NSString *)zapperHandle zappedAt:(int64_t)zappedAt message:(NSString * _Nullable)message amountInSats:(uint64_t)amountInSats zapperInternetIdentifier:(NSString * _Nullable)zapperInternetIdentifier zapperAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)zapperAvatarCdnImage zapperLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)zapperLegendProfile __attribute__((swift_name("doCopy(id:zapperId:zapperName:zapperHandle:zappedAt:message:amountInSats:zapperInternetIdentifier:zapperAvatarCdnImage:zapperLegendProfile:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventZap.Companion")))
@interface PrimalSharedEventZapCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedEventZapCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) id<PrimalSharedKotlinComparator> DefaultComparator __attribute__((swift_name("DefaultComparator")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEventAction")))
@interface PrimalSharedNostrEventAction : PrimalSharedBase
@property (readonly) PrimalSharedNostrEvent *actionEventData __attribute__((swift_name("actionEventData")));
@property (readonly) int32_t actionEventKind __attribute__((swift_name("actionEventKind")));
@property (readonly) PrimalSharedProfileData *profile __attribute__((swift_name("profile")));
@property (readonly) float score __attribute__((swift_name("score")));
- (instancetype)initWithProfile:(PrimalSharedProfileData *)profile score:(float)score actionEventData:(PrimalSharedNostrEvent *)actionEventData actionEventKind:(int32_t)actionEventKind __attribute__((swift_name("init(profile:score:actionEventData:actionEventKind:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrEventAction *)doCopyProfile:(PrimalSharedProfileData *)profile score:(float)score actionEventData:(PrimalSharedNostrEvent *)actionEventData actionEventKind:(int32_t)actionEventKind __attribute__((swift_name("doCopy(profile:score:actionEventData:actionEventKind:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEventStats")))
@interface PrimalSharedNostrEventStats : PrimalSharedBase
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) PrimalSharedLong * _Nullable likes __attribute__((swift_name("likes")));
@property (readonly) PrimalSharedLong * _Nullable mentions __attribute__((swift_name("mentions")));
@property (readonly) PrimalSharedLong * _Nullable replies __attribute__((swift_name("replies")));
@property (readonly) PrimalSharedLong * _Nullable reposts __attribute__((swift_name("reposts")));
@property (readonly) PrimalSharedLong * _Nullable satsZapped __attribute__((swift_name("satsZapped")));
@property (readonly) PrimalSharedLong * _Nullable score __attribute__((swift_name("score")));
@property (readonly) PrimalSharedLong * _Nullable score24h __attribute__((swift_name("score24h")));
@property (readonly) PrimalSharedLong * _Nullable zaps __attribute__((swift_name("zaps")));
- (instancetype)initWithEventId:(NSString *)eventId likes:(PrimalSharedLong * _Nullable)likes replies:(PrimalSharedLong * _Nullable)replies mentions:(PrimalSharedLong * _Nullable)mentions reposts:(PrimalSharedLong * _Nullable)reposts zaps:(PrimalSharedLong * _Nullable)zaps satsZapped:(PrimalSharedLong * _Nullable)satsZapped score:(PrimalSharedLong * _Nullable)score score24h:(PrimalSharedLong * _Nullable)score24h __attribute__((swift_name("init(eventId:likes:replies:mentions:reposts:zaps:satsZapped:score:score24h:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrEventStats *)doCopyEventId:(NSString *)eventId likes:(PrimalSharedLong * _Nullable)likes replies:(PrimalSharedLong * _Nullable)replies mentions:(PrimalSharedLong * _Nullable)mentions reposts:(PrimalSharedLong * _Nullable)reposts zaps:(PrimalSharedLong * _Nullable)zaps satsZapped:(PrimalSharedLong * _Nullable)satsZapped score:(PrimalSharedLong * _Nullable)score score24h:(PrimalSharedLong * _Nullable)score24h __attribute__((swift_name("doCopy(eventId:likes:replies:mentions:reposts:zaps:satsZapped:score:score24h:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEventUserStats")))
@interface PrimalSharedNostrEventUserStats : PrimalSharedBase
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) BOOL liked __attribute__((swift_name("liked")));
@property (readonly) BOOL replied __attribute__((swift_name("replied")));
@property (readonly) BOOL reposted __attribute__((swift_name("reposted")));
@property (readonly) NSString *userId __attribute__((swift_name("userId")));
@property (readonly) BOOL zapped __attribute__((swift_name("zapped")));
- (instancetype)initWithEventId:(NSString *)eventId userId:(NSString *)userId replied:(BOOL)replied liked:(BOOL)liked reposted:(BOOL)reposted zapped:(BOOL)zapped __attribute__((swift_name("init(eventId:userId:replied:liked:reposted:zapped:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrEventUserStats *)doCopyEventId:(NSString *)eventId userId:(NSString *)userId replied:(BOOL)replied liked:(BOOL)liked reposted:(BOOL)reposted zapped:(BOOL)zapped __attribute__((swift_name("doCopy(eventId:userId:replied:liked:reposted:zapped:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ExplorePeopleData")))
@interface PrimalSharedExplorePeopleData : PrimalSharedBase
@property (readonly) int32_t followersIncrease __attribute__((swift_name("followersIncrease")));
@property (readonly) PrimalSharedProfileData *profile __attribute__((swift_name("profile")));
@property (readonly) int32_t userFollowersCount __attribute__((swift_name("userFollowersCount")));
@property (readonly) float userScore __attribute__((swift_name("userScore")));
@property (readonly) int32_t verifiedFollowersCount __attribute__((swift_name("verifiedFollowersCount")));
- (instancetype)initWithProfile:(PrimalSharedProfileData *)profile userScore:(float)userScore userFollowersCount:(int32_t)userFollowersCount followersIncrease:(int32_t)followersIncrease verifiedFollowersCount:(int32_t)verifiedFollowersCount __attribute__((swift_name("init(profile:userScore:userFollowersCount:followersIncrease:verifiedFollowersCount:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedExplorePeopleData *)doCopyProfile:(PrimalSharedProfileData *)profile userScore:(float)userScore userFollowersCount:(int32_t)userFollowersCount followersIncrease:(int32_t)followersIncrease verifiedFollowersCount:(int32_t)verifiedFollowersCount __attribute__((swift_name("doCopy(profile:userScore:userFollowersCount:followersIncrease:verifiedFollowersCount:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("ExploreRepository")))
@protocol PrimalSharedExploreRepository
@required

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchFollowListProfileId:(NSString *)profileId identifier:(NSString *)identifier completionHandler:(void (^)(PrimalSharedFollowPack * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchFollowList(profileId:identifier:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchFollowListsSince:(PrimalSharedLong * _Nullable)since until:(PrimalSharedLong * _Nullable)until limit:(int32_t)limit offset:(PrimalSharedInt * _Nullable)offset completionHandler:(void (^)(NSArray<PrimalSharedFollowPack *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchFollowLists(since:until:limit:offset:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchPopularUsersWithCompletionHandler:(void (^)(NSArray<PrimalSharedUserProfileSearchItem *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchPopularUsers(completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchTrendingPeopleUserId:(NSString *)userId completionHandler:(void (^)(NSArray<PrimalSharedExplorePeopleData *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchTrendingPeople(userId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchTrendingTopicsWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchTrendingTopics(completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchTrendingZapsUserId:(NSString *)userId completionHandler:(void (^)(NSArray<PrimalSharedExploreZapNoteData *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchTrendingZaps(userId:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)getFollowLists __attribute__((swift_name("getFollowLists()")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeFollowListProfileId:(NSString *)profileId identifier:(NSString *)identifier __attribute__((swift_name("observeFollowList(profileId:identifier:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeTrendingTopics __attribute__((swift_name("observeTrendingTopics()")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)searchUsersQuery:(NSString *)query limit:(int32_t)limit completionHandler:(void (^)(NSArray<PrimalSharedUserProfileSearchItem *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("searchUsers(query:limit:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ExploreTrendingTopic")))
@interface PrimalSharedExploreTrendingTopic : PrimalSharedBase
@property (readonly) float score __attribute__((swift_name("score")));
@property (readonly) NSString *topic __attribute__((swift_name("topic")));
- (instancetype)initWithTopic:(NSString *)topic score:(float)score __attribute__((swift_name("init(topic:score:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedExploreTrendingTopic *)doCopyTopic:(NSString *)topic score:(float)score __attribute__((swift_name("doCopy(topic:score:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ExploreZapNoteData")))
@interface PrimalSharedExploreZapNoteData : PrimalSharedBase
@property (readonly) uint64_t amountSats __attribute__((swift_name("amountSats")));
@property (readonly) PrimalSharedKotlinx_datetimeInstant *createdAt __attribute__((swift_name("createdAt")));
@property (readonly) PrimalSharedFeedPost *noteData __attribute__((swift_name("noteData")));
@property (readonly) NSArray<PrimalSharedEventUriNostrReference *> *noteNostrUris __attribute__((swift_name("noteNostrUris")));
@property (readonly) PrimalSharedProfileData * _Nullable receiver __attribute__((swift_name("receiver")));
@property (readonly) PrimalSharedProfileData * _Nullable sender __attribute__((swift_name("sender")));
@property (readonly) NSString * _Nullable zapMessage __attribute__((swift_name("zapMessage")));
- (instancetype)initWithSender:(PrimalSharedProfileData * _Nullable)sender receiver:(PrimalSharedProfileData * _Nullable)receiver noteData:(PrimalSharedFeedPost *)noteData amountSats:(uint64_t)amountSats zapMessage:(NSString * _Nullable)zapMessage createdAt:(PrimalSharedKotlinx_datetimeInstant *)createdAt noteNostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)noteNostrUris __attribute__((swift_name("init(sender:receiver:noteData:amountSats:zapMessage:createdAt:noteNostrUris:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedExploreZapNoteData *)doCopySender:(PrimalSharedProfileData * _Nullable)sender receiver:(PrimalSharedProfileData * _Nullable)receiver noteData:(PrimalSharedFeedPost *)noteData amountSats:(uint64_t)amountSats zapMessage:(NSString * _Nullable)zapMessage createdAt:(PrimalSharedKotlinx_datetimeInstant *)createdAt noteNostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)noteNostrUris __attribute__((swift_name("doCopy(sender:receiver:noteData:amountSats:zapMessage:createdAt:noteNostrUris:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FollowPack")))
@interface PrimalSharedFollowPack : PrimalSharedBase
@property (readonly) NSString *authorId __attribute__((swift_name("authorId")));
@property (readonly) PrimalSharedFollowPackProfileData * _Nullable authorProfileData __attribute__((swift_name("authorProfileData")));
@property (readonly) PrimalSharedCdnImage * _Nullable coverCdnImage __attribute__((swift_name("coverCdnImage")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSString *identifier __attribute__((swift_name("identifier")));
@property (readonly) NSArray<PrimalSharedFollowPackProfileData *> *profiles __attribute__((swift_name("profiles")));
@property (readonly) int32_t profilesCount __attribute__((swift_name("profilesCount")));
@property (readonly) NSString *title __attribute__((swift_name("title")));
@property (readonly) int64_t updatedAt __attribute__((swift_name("updatedAt")));
- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title coverCdnImage:(PrimalSharedCdnImage * _Nullable)coverCdnImage description:(NSString * _Nullable)description authorId:(NSString *)authorId authorProfileData:(PrimalSharedFollowPackProfileData * _Nullable)authorProfileData profilesCount:(int32_t)profilesCount profiles:(NSArray<PrimalSharedFollowPackProfileData *> *)profiles updatedAt:(int64_t)updatedAt __attribute__((swift_name("init(identifier:title:coverCdnImage:description:authorId:authorProfileData:profilesCount:profiles:updatedAt:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFollowPack *)doCopyIdentifier:(NSString *)identifier title:(NSString *)title coverCdnImage:(PrimalSharedCdnImage * _Nullable)coverCdnImage description:(NSString * _Nullable)description authorId:(NSString *)authorId authorProfileData:(PrimalSharedFollowPackProfileData * _Nullable)authorProfileData profilesCount:(int32_t)profilesCount profiles:(NSArray<PrimalSharedFollowPackProfileData *> *)profiles updatedAt:(int64_t)updatedAt __attribute__((swift_name("doCopy(identifier:title:coverCdnImage:description:authorId:authorProfileData:profilesCount:profiles:updatedAt:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FollowPackProfileData")))
@interface PrimalSharedFollowPackProfileData : PrimalSharedBase
@property (readonly) PrimalSharedCdnImage * _Nullable avatarCdnImage __attribute__((swift_name("avatarCdnImage")));
@property (readonly) NSString *displayName __attribute__((swift_name("displayName")));
@property (readonly) int32_t followersCount __attribute__((swift_name("followersCount")));
@property (readonly) NSString * _Nullable internetIdentifier __attribute__((swift_name("internetIdentifier")));
@property (readonly) PrimalSharedPrimalPremiumInfo * _Nullable primalPremiumInfo __attribute__((swift_name("primalPremiumInfo")));
@property (readonly) NSString *profileId __attribute__((swift_name("profileId")));
- (instancetype)initWithProfileId:(NSString *)profileId displayName:(NSString *)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier followersCount:(int32_t)followersCount avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage primalPremiumInfo:(PrimalSharedPrimalPremiumInfo * _Nullable)primalPremiumInfo __attribute__((swift_name("init(profileId:displayName:internetIdentifier:followersCount:avatarCdnImage:primalPremiumInfo:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFollowPackProfileData *)doCopyProfileId:(NSString *)profileId displayName:(NSString *)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier followersCount:(int32_t)followersCount avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage primalPremiumInfo:(PrimalSharedPrimalPremiumInfo * _Nullable)primalPremiumInfo __attribute__((swift_name("doCopy(profileId:displayName:internetIdentifier:followersCount:avatarCdnImage:primalPremiumInfo:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DvmFeed")))
@interface PrimalSharedDvmFeed : PrimalSharedBase
@property (readonly) NSArray<NSString *> *actionUserIds __attribute__((swift_name("actionUserIds")));
@property (readonly) NSString * _Nullable amountInSats __attribute__((swift_name("amountInSats")));
@property (readonly) NSString * _Nullable avatarUrl __attribute__((swift_name("avatarUrl")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSString *dvmId __attribute__((swift_name("dvmId")));
@property (readonly) NSString * _Nullable dvmLnUrlDecoded __attribute__((swift_name("dvmLnUrlDecoded")));
@property (readonly) NSString *dvmPubkey __attribute__((swift_name("dvmPubkey")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) BOOL isPaid __attribute__((swift_name("isPaid")));
@property (readonly) PrimalSharedBoolean * _Nullable isPrimalFeed __attribute__((swift_name("isPrimalFeed")));
@property (readonly) PrimalSharedFeedSpecKind * _Nullable kind __attribute__((swift_name("kind")));
@property (readonly) NSString * _Nullable primalSpec __attribute__((swift_name("primalSpec")));
@property (readonly) PrimalSharedBoolean * _Nullable primalSubscriptionRequired __attribute__((swift_name("primalSubscriptionRequired")));
@property (readonly) NSString *title __attribute__((swift_name("title")));
- (instancetype)initWithEventId:(NSString *)eventId dvmPubkey:(NSString *)dvmPubkey dvmId:(NSString *)dvmId dvmLnUrlDecoded:(NSString * _Nullable)dvmLnUrlDecoded title:(NSString *)title description:(NSString * _Nullable)description avatarUrl:(NSString * _Nullable)avatarUrl amountInSats:(NSString * _Nullable)amountInSats primalSpec:(NSString * _Nullable)primalSpec primalSubscriptionRequired:(PrimalSharedBoolean * _Nullable)primalSubscriptionRequired isPaid:(BOOL)isPaid kind:(PrimalSharedFeedSpecKind * _Nullable)kind isPrimalFeed:(PrimalSharedBoolean * _Nullable)isPrimalFeed actionUserIds:(NSArray<NSString *> *)actionUserIds __attribute__((swift_name("init(eventId:dvmPubkey:dvmId:dvmLnUrlDecoded:title:description:avatarUrl:amountInSats:primalSpec:primalSubscriptionRequired:isPaid:kind:isPrimalFeed:actionUserIds:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedDvmFeed *)doCopyEventId:(NSString *)eventId dvmPubkey:(NSString *)dvmPubkey dvmId:(NSString *)dvmId dvmLnUrlDecoded:(NSString * _Nullable)dvmLnUrlDecoded title:(NSString *)title description:(NSString * _Nullable)description avatarUrl:(NSString * _Nullable)avatarUrl amountInSats:(NSString * _Nullable)amountInSats primalSpec:(NSString * _Nullable)primalSpec primalSubscriptionRequired:(PrimalSharedBoolean * _Nullable)primalSubscriptionRequired isPaid:(BOOL)isPaid kind:(PrimalSharedFeedSpecKind * _Nullable)kind isPrimalFeed:(PrimalSharedBoolean * _Nullable)isPrimalFeed actionUserIds:(NSArray<NSString *> *)actionUserIds __attribute__((swift_name("doCopy(eventId:dvmPubkey:dvmId:dvmLnUrlDecoded:title:description:avatarUrl:amountInSats:primalSpec:primalSubscriptionRequired:isPaid:kind:isPrimalFeed:actionUserIds:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedSpecKind")))
@interface PrimalSharedFeedSpecKind : PrimalSharedKotlinEnum<PrimalSharedFeedSpecKind *>
@property (class, readonly) PrimalSharedFeedSpecKind *reads __attribute__((swift_name("reads")));
@property (class, readonly) PrimalSharedFeedSpecKind *notes __attribute__((swift_name("notes")));
@property (class, readonly) NSArray<PrimalSharedFeedSpecKind *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) NSString *settingsKey __attribute__((swift_name("settingsKey")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedFeedSpecKind *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((swift_name("FeedsRepository")))
@protocol PrimalSharedFeedsRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)addDvmFeedLocallyUserId:(NSString *)userId dvmFeed:(PrimalSharedDvmFeed *)dvmFeed specKind:(PrimalSharedFeedSpecKind *)specKind completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("addDvmFeedLocally(userId:dvmFeed:specKind:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)addFeedLocallyUserId:(NSString *)userId feedSpec:(NSString *)feedSpec title:(NSString *)title description:(NSString *)description feedSpecKind:(PrimalSharedFeedSpecKind *)feedSpecKind feedKind:(NSString *)feedKind completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("addFeedLocally(userId:feedSpec:title:description:feedSpecKind:feedKind:completionHandler:)")));

/**
 * @note This method converts instances of SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchAndPersistArticleFeedsUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchAndPersistArticleFeeds(userId:completionHandler:)")));

/**
 * @note This method converts instances of SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchAndPersistDefaultFeedsUserId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind givenDefaultFeeds:(NSArray<PrimalSharedPrimalFeed *> *)givenDefaultFeeds completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchAndPersistDefaultFeeds(userId:specKind:givenDefaultFeeds:completionHandler:)")));

/**
 * @note This method converts instances of SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchAndPersistNoteFeedsUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchAndPersistNoteFeeds(userId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchDefaultFeedsUserId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind completionHandler:(void (^)(NSArray<PrimalSharedPrimalFeed *> * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchDefaultFeeds(userId:specKind:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchRecommendedDvmFeedsUserId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind * _Nullable)specKind completionHandler:(void (^)(NSArray<PrimalSharedDvmFeed *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchRecommendedDvmFeeds(userId:specKind:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeAllFeedsUserId:(NSString *)userId __attribute__((swift_name("observeAllFeeds(userId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeContainsFeedSpecUserId:(NSString *)userId feedSpec:(NSString *)feedSpec __attribute__((swift_name("observeContainsFeedSpec(userId:feedSpec:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeFeedsUserId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind __attribute__((swift_name("observeFeeds(userId:specKind:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeNotesFeedsUserId:(NSString *)userId __attribute__((swift_name("observeNotesFeeds(userId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeReadsFeedsUserId:(NSString *)userId __attribute__((swift_name("observeReadsFeeds(userId:)")));

/**
 * @note This method converts instances of SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)persistLocallyAndRemotelyUserFeedsUserId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind feeds:(NSArray<PrimalSharedPrimalFeed *> *)feeds completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("persistLocallyAndRemotelyUserFeeds(userId:specKind:feeds:completionHandler:)")));

/**
 * @note This method converts instances of SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)persistNewDefaultFeedsUserId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind givenDefaultFeeds:(NSArray<PrimalSharedPrimalFeed *> *)givenDefaultFeeds completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("persistNewDefaultFeeds(userId:specKind:givenDefaultFeeds:completionHandler:)")));

/**
 * @note This method converts instances of SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)persistRemotelyAllLocalUserFeedsUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("persistRemotelyAllLocalUserFeeds(userId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)removeFeedLocallyUserId:(NSString *)userId feedSpec:(NSString *)feedSpec completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("removeFeedLocally(userId:feedSpec:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalFeed")))
@interface PrimalSharedPrimalFeed : PrimalSharedBase
@property (readonly) NSString *description_ __attribute__((swift_name("description_")));
@property (readonly) BOOL enabled __attribute__((swift_name("enabled")));
@property (readonly) NSString *feedKind __attribute__((swift_name("feedKind")));
@property (readonly) NSString *ownerId __attribute__((swift_name("ownerId")));
@property (readonly) int32_t position __attribute__((swift_name("position")));
@property (readonly) NSString *spec __attribute__((swift_name("spec")));
@property (readonly) PrimalSharedFeedSpecKind *specKind __attribute__((swift_name("specKind")));
@property (readonly) NSString *title __attribute__((swift_name("title")));
- (instancetype)initWithOwnerId:(NSString *)ownerId spec:(NSString *)spec specKind:(PrimalSharedFeedSpecKind *)specKind feedKind:(NSString *)feedKind title:(NSString *)title description:(NSString *)description enabled:(BOOL)enabled position:(int32_t)position __attribute__((swift_name("init(ownerId:spec:specKind:feedKind:title:description:enabled:position:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalFeed *)doCopyOwnerId:(NSString *)ownerId spec:(NSString *)spec specKind:(PrimalSharedFeedSpecKind *)specKind feedKind:(NSString *)feedKind title:(NSString *)title description:(NSString *)description enabled:(BOOL)enabled position:(int32_t)position __attribute__((swift_name("doCopy(ownerId:spec:specKind:feedKind:title:description:enabled:position:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AppConfig")))
@interface PrimalSharedAppConfig : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedAppConfigCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *cacheUrl __attribute__((swift_name("cacheUrl")));
@property (readonly) BOOL cacheUrlOverride __attribute__((swift_name("cacheUrlOverride")));
@property (readonly) NSString *uploadUrl __attribute__((swift_name("uploadUrl")));
@property (readonly) NSString *walletUrl __attribute__((swift_name("walletUrl")));
- (instancetype)initWithCacheUrl:(NSString *)cacheUrl cacheUrlOverride:(BOOL)cacheUrlOverride uploadUrl:(NSString *)uploadUrl walletUrl:(NSString *)walletUrl __attribute__((swift_name("init(cacheUrl:cacheUrlOverride:uploadUrl:walletUrl:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedAppConfig *)doCopyCacheUrl:(NSString *)cacheUrl cacheUrlOverride:(BOOL)cacheUrlOverride uploadUrl:(NSString *)uploadUrl walletUrl:(NSString *)walletUrl __attribute__((swift_name("doCopy(cacheUrl:cacheUrlOverride:uploadUrl:walletUrl:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("AppConfig.Companion")))
@interface PrimalSharedAppConfigCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedAppConfigCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("CachingImportRepository")))
@protocol PrimalSharedCachingImportRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)cacheEventsNostrEvents:(NSArray<PrimalSharedNostrEvent *> *)nostrEvents primalEvents:(NSArray<PrimalSharedPrimalEvent *> *)primalEvents completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("cacheEvents(nostrEvents:primalEvents:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)cacheNostrEventsEvents:(PrimalSharedKotlinArray<PrimalSharedNostrEvent *> *)events completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("cacheNostrEvents(events:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)cacheNostrEventsEvents:(NSArray<PrimalSharedNostrEvent *> *)events completionHandler_:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("cacheNostrEvents(events:completionHandler_:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)cachePrimalEventsEvents:(PrimalSharedKotlinArray<PrimalSharedPrimalEvent *> *)events completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("cachePrimalEvents(events:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)cachePrimalEventsEvents:(NSArray<PrimalSharedPrimalEvent *> *)events completionHandler_:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("cachePrimalEvents(events:completionHandler_:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentAppSettings")))
@interface PrimalSharedContentAppSettings : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedContentAppSettingsCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedULong * _Nullable defaultZapAmount __attribute__((swift_name("defaultZapAmount"))) __attribute__((deprecated("Replaced with zapDefault.")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *notifications __attribute__((swift_name("notifications")));
@property (readonly) NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *notificationsAdditional __attribute__((swift_name("notificationsAdditional")));
@property (readonly) NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *pushNotifications __attribute__((swift_name("pushNotifications")));
@property (readonly) PrimalSharedContentZapDefault * _Nullable zapDefault __attribute__((swift_name("zapDefault")));
@property (readonly) NSArray<PrimalSharedULong *> *zapOptions __attribute__((swift_name("zapOptions"))) __attribute__((deprecated("Replaced with zapsConfig.")));
@property (readonly) NSArray<PrimalSharedContentZapConfigItem *> *zapsConfig __attribute__((swift_name("zapsConfig")));
- (instancetype)initWithDescription:(NSString * _Nullable)description notifications:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)notifications pushNotifications:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)pushNotifications notificationsAdditional:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)notificationsAdditional defaultZapAmount:(PrimalSharedULong * _Nullable)defaultZapAmount zapOptions:(NSArray<PrimalSharedULong *> *)zapOptions zapDefault:(PrimalSharedContentZapDefault * _Nullable)zapDefault zapsConfig:(NSArray<PrimalSharedContentZapConfigItem *> *)zapsConfig __attribute__((swift_name("init(description:notifications:pushNotifications:notificationsAdditional:defaultZapAmount:zapOptions:zapDefault:zapsConfig:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedContentAppSettings *)doCopyDescription:(NSString * _Nullable)description notifications:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)notifications pushNotifications:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)pushNotifications notificationsAdditional:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)notificationsAdditional defaultZapAmount:(PrimalSharedULong * _Nullable)defaultZapAmount zapOptions:(NSArray<PrimalSharedULong *> *)zapOptions zapDefault:(PrimalSharedContentZapDefault * _Nullable)zapDefault zapsConfig:(NSArray<PrimalSharedContentZapConfigItem *> *)zapsConfig __attribute__((swift_name("doCopy(description:notifications:pushNotifications:notificationsAdditional:defaultZapAmount:zapOptions:zapDefault:zapsConfig:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="zapConfig")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentAppSettings.Companion")))
@interface PrimalSharedContentAppSettingsCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedContentAppSettingsCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalServerType")))
@interface PrimalSharedPrimalServerType : PrimalSharedKotlinEnum<PrimalSharedPrimalServerType *>
@property (class, readonly) PrimalSharedPrimalServerType *caching __attribute__((swift_name("caching")));
@property (class, readonly) PrimalSharedPrimalServerType *upload __attribute__((swift_name("upload")));
@property (class, readonly) PrimalSharedPrimalServerType *wallet __attribute__((swift_name("wallet")));
@property (class, readonly) NSArray<PrimalSharedPrimalServerType *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedPrimalServerType *> *)values __attribute__((swift_name("values()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CdnImage")))
@interface PrimalSharedCdnImage : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedCdnImageCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *sourceUrl __attribute__((swift_name("sourceUrl")));
@property (readonly) NSArray<PrimalSharedCdnResourceVariant *> *variants __attribute__((swift_name("variants")));
- (instancetype)initWithSourceUrl:(NSString *)sourceUrl variants:(NSArray<PrimalSharedCdnResourceVariant *> *)variants __attribute__((swift_name("init(sourceUrl:variants:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedCdnImage *)doCopySourceUrl:(NSString *)sourceUrl variants:(NSArray<PrimalSharedCdnResourceVariant *> *)variants __attribute__((swift_name("doCopy(sourceUrl:variants:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CdnImage.Companion")))
@interface PrimalSharedCdnImageCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedCdnImageCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CdnResource")))
@interface PrimalSharedCdnResource : PrimalSharedBase
@property (readonly) NSString * _Nullable contentType __attribute__((swift_name("contentType")));
@property (readonly) NSString *url __attribute__((swift_name("url")));
@property (readonly) NSArray<PrimalSharedCdnResourceVariant *> * _Nullable variants __attribute__((swift_name("variants")));
- (instancetype)initWithUrl:(NSString *)url contentType:(NSString * _Nullable)contentType variants:(NSArray<PrimalSharedCdnResourceVariant *> * _Nullable)variants __attribute__((swift_name("init(url:contentType:variants:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedCdnResource *)doCopyUrl:(NSString *)url contentType:(NSString * _Nullable)contentType variants:(NSArray<PrimalSharedCdnResourceVariant *> * _Nullable)variants __attribute__((swift_name("doCopy(url:contentType:variants:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CdnResourceVariant")))
@interface PrimalSharedCdnResourceVariant : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedCdnResourceVariantCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t height __attribute__((swift_name("height")));
@property (readonly) NSString *mediaUrl __attribute__((swift_name("mediaUrl")));
@property (readonly) int32_t width __attribute__((swift_name("width")));
- (instancetype)initWithWidth:(int32_t)width height:(int32_t)height mediaUrl:(NSString *)mediaUrl __attribute__((swift_name("init(width:height:mediaUrl:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedCdnResourceVariant *)doCopyWidth:(int32_t)width height:(int32_t)height mediaUrl:(NSString *)mediaUrl __attribute__((swift_name("doCopy(width:height:mediaUrl:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CdnResourceVariant.Companion")))
@interface PrimalSharedCdnResourceVariantCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedCdnResourceVariantCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventLink")))
@interface PrimalSharedEventLink : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedEventLinkCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString * _Nullable authorAvatarUrl __attribute__((swift_name("authorAvatarUrl")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) NSString * _Nullable mimeType __attribute__((swift_name("mimeType")));
@property (readonly) int32_t position __attribute__((swift_name("position")));
@property (readonly) NSString * _Nullable thumbnail __attribute__((swift_name("thumbnail")));
@property (readonly) NSString * _Nullable title __attribute__((swift_name("title")));
@property (readonly) PrimalSharedEventUriType *type __attribute__((swift_name("type")));
@property (readonly) NSString *url __attribute__((swift_name("url")));
@property (readonly) NSArray<PrimalSharedCdnResourceVariant *> * _Nullable variants __attribute__((swift_name("variants")));
- (instancetype)initWithEventId:(NSString *)eventId position:(int32_t)position url:(NSString *)url type:(PrimalSharedEventUriType *)type mimeType:(NSString * _Nullable)mimeType variants:(NSArray<PrimalSharedCdnResourceVariant *> * _Nullable)variants title:(NSString * _Nullable)title description:(NSString * _Nullable)description thumbnail:(NSString * _Nullable)thumbnail authorAvatarUrl:(NSString * _Nullable)authorAvatarUrl __attribute__((swift_name("init(eventId:position:url:type:mimeType:variants:title:description:thumbnail:authorAvatarUrl:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedEventLink *)doCopyEventId:(NSString *)eventId position:(int32_t)position url:(NSString *)url type:(PrimalSharedEventUriType *)type mimeType:(NSString * _Nullable)mimeType variants:(NSArray<PrimalSharedCdnResourceVariant *> * _Nullable)variants title:(NSString * _Nullable)title description:(NSString * _Nullable)description thumbnail:(NSString * _Nullable)thumbnail authorAvatarUrl:(NSString * _Nullable)authorAvatarUrl __attribute__((swift_name("doCopy(eventId:position:url:type:mimeType:variants:title:description:thumbnail:authorAvatarUrl:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventLink.Companion")))
@interface PrimalSharedEventLinkCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedEventLinkCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventLinkPreviewData")))
@interface PrimalSharedEventLinkPreviewData : PrimalSharedBase
@property (readonly) NSString * _Nullable authorAvatarUrl __attribute__((swift_name("authorAvatarUrl")));
@property (readonly) NSString * _Nullable description_ __attribute__((swift_name("description_")));
@property (readonly) NSString * _Nullable mimeType __attribute__((swift_name("mimeType")));
@property (readonly) NSString * _Nullable thumbnailUrl __attribute__((swift_name("thumbnailUrl")));
@property (readonly) NSString * _Nullable title __attribute__((swift_name("title")));
@property (readonly) NSString *url __attribute__((swift_name("url")));
- (instancetype)initWithUrl:(NSString *)url mimeType:(NSString * _Nullable)mimeType title:(NSString * _Nullable)title description:(NSString * _Nullable)description thumbnailUrl:(NSString * _Nullable)thumbnailUrl authorAvatarUrl:(NSString * _Nullable)authorAvatarUrl __attribute__((swift_name("init(url:mimeType:title:description:thumbnailUrl:authorAvatarUrl:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedEventLinkPreviewData *)doCopyUrl:(NSString *)url mimeType:(NSString * _Nullable)mimeType title:(NSString * _Nullable)title description:(NSString * _Nullable)description thumbnailUrl:(NSString * _Nullable)thumbnailUrl authorAvatarUrl:(NSString * _Nullable)authorAvatarUrl __attribute__((swift_name("doCopy(url:mimeType:title:description:thumbnailUrl:authorAvatarUrl:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventUriNostrReference")))
@interface PrimalSharedEventUriNostrReference : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedEventUriNostrReferenceCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) PrimalSharedInt * _Nullable position __attribute__((swift_name("position")));
@property (readonly) PrimalSharedReferencedArticle * _Nullable referencedArticle __attribute__((swift_name("referencedArticle")));
@property (readonly) NSString * _Nullable referencedEventAlt __attribute__((swift_name("referencedEventAlt")));
@property (readonly) PrimalSharedReferencedHighlight * _Nullable referencedHighlight __attribute__((swift_name("referencedHighlight")));
@property (readonly) PrimalSharedReferencedNote * _Nullable referencedNote __attribute__((swift_name("referencedNote")));
@property (readonly) PrimalSharedReferencedUser * _Nullable referencedUser __attribute__((swift_name("referencedUser")));
@property (readonly) PrimalSharedReferencedZap * _Nullable referencedZap __attribute__((swift_name("referencedZap")));
@property (readonly) PrimalSharedEventUriNostrType *type __attribute__((swift_name("type")));
@property (readonly) NSString *uri __attribute__((swift_name("uri")));
- (instancetype)initWithEventId:(NSString *)eventId uri:(NSString *)uri type:(PrimalSharedEventUriNostrType *)type position:(PrimalSharedInt * _Nullable)position referencedEventAlt:(NSString * _Nullable)referencedEventAlt referencedHighlight:(PrimalSharedReferencedHighlight * _Nullable)referencedHighlight referencedNote:(PrimalSharedReferencedNote * _Nullable)referencedNote referencedArticle:(PrimalSharedReferencedArticle * _Nullable)referencedArticle referencedUser:(PrimalSharedReferencedUser * _Nullable)referencedUser referencedZap:(PrimalSharedReferencedZap * _Nullable)referencedZap __attribute__((swift_name("init(eventId:uri:type:position:referencedEventAlt:referencedHighlight:referencedNote:referencedArticle:referencedUser:referencedZap:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedEventUriNostrReference *)doCopyEventId:(NSString *)eventId uri:(NSString *)uri type:(PrimalSharedEventUriNostrType *)type position:(PrimalSharedInt * _Nullable)position referencedEventAlt:(NSString * _Nullable)referencedEventAlt referencedHighlight:(PrimalSharedReferencedHighlight * _Nullable)referencedHighlight referencedNote:(PrimalSharedReferencedNote * _Nullable)referencedNote referencedArticle:(PrimalSharedReferencedArticle * _Nullable)referencedArticle referencedUser:(PrimalSharedReferencedUser * _Nullable)referencedUser referencedZap:(PrimalSharedReferencedZap * _Nullable)referencedZap __attribute__((swift_name("doCopy(eventId:uri:type:position:referencedEventAlt:referencedHighlight:referencedNote:referencedArticle:referencedUser:referencedZap:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventUriNostrReference.Companion")))
@interface PrimalSharedEventUriNostrReferenceCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedEventUriNostrReferenceCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventUriNostrType")))
@interface PrimalSharedEventUriNostrType : PrimalSharedKotlinEnum<PrimalSharedEventUriNostrType *>
@property (class, readonly) PrimalSharedEventUriNostrType *zap __attribute__((swift_name("zap")));
@property (class, readonly) PrimalSharedEventUriNostrType *note __attribute__((swift_name("note")));
@property (class, readonly) PrimalSharedEventUriNostrType *profile __attribute__((swift_name("profile")));
@property (class, readonly) PrimalSharedEventUriNostrType *article __attribute__((swift_name("article")));
@property (class, readonly) PrimalSharedEventUriNostrType *highlight __attribute__((swift_name("highlight")));
@property (class, readonly) PrimalSharedEventUriNostrType *unsupported __attribute__((swift_name("unsupported")));
@property (class, readonly) NSArray<PrimalSharedEventUriNostrType *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedEventUriNostrType *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((swift_name("EventUriRepository")))
@protocol PrimalSharedEventUriRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)loadEventLinksNoteId:(NSString *)noteId types:(NSArray<PrimalSharedEventUriType *> *)types completionHandler:(void (^)(NSArray<PrimalSharedEventLink *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("loadEventLinks(noteId:types:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("EventUriType")))
@interface PrimalSharedEventUriType : PrimalSharedKotlinEnum<PrimalSharedEventUriType *>
@property (class, readonly) PrimalSharedEventUriType *image __attribute__((swift_name("image")));
@property (class, readonly) PrimalSharedEventUriType *video __attribute__((swift_name("video")));
@property (class, readonly) PrimalSharedEventUriType *audio __attribute__((swift_name("audio")));
@property (class, readonly) PrimalSharedEventUriType *pdf __attribute__((swift_name("pdf")));
@property (class, readonly) PrimalSharedEventUriType *youtube __attribute__((swift_name("youtube")));
@property (class, readonly) PrimalSharedEventUriType *rumble __attribute__((swift_name("rumble")));
@property (class, readonly) PrimalSharedEventUriType *spotify __attribute__((swift_name("spotify")));
@property (class, readonly) PrimalSharedEventUriType *tidal __attribute__((swift_name("tidal")));
@property (class, readonly) PrimalSharedEventUriType *github __attribute__((swift_name("github")));
@property (class, readonly) PrimalSharedEventUriType *other __attribute__((swift_name("other")));
@property (class, readonly) NSArray<PrimalSharedEventUriType *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedEventUriType *> *)values __attribute__((swift_name("values()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedArticle")))
@interface PrimalSharedReferencedArticle : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedReferencedArticleCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *aTag __attribute__((swift_name("aTag")));
@property (readonly) NSString *articleId __attribute__((swift_name("articleId")));
@property (readonly) PrimalSharedCdnImage * _Nullable articleImageCdnImage __attribute__((swift_name("articleImageCdnImage")));
@property (readonly) PrimalSharedInt * _Nullable articleReadingTimeInMinutes __attribute__((swift_name("articleReadingTimeInMinutes")));
@property (readonly) NSString *articleTitle __attribute__((swift_name("articleTitle")));
@property (readonly) PrimalSharedCdnImage * _Nullable authorAvatarCdnImage __attribute__((swift_name("authorAvatarCdnImage")));
@property (readonly) NSString *authorId __attribute__((swift_name("authorId")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable authorLegendProfile __attribute__((swift_name("authorLegendProfile")));
@property (readonly) NSString *authorName __attribute__((swift_name("authorName")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) NSString *naddr __attribute__((swift_name("naddr")));
@property (readonly) NSString *raw __attribute__((swift_name("raw")));
- (instancetype)initWithNaddr:(NSString *)naddr aTag:(NSString *)aTag eventId:(NSString *)eventId articleId:(NSString *)articleId articleTitle:(NSString *)articleTitle authorId:(NSString *)authorId authorName:(NSString *)authorName authorAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)authorAvatarCdnImage authorLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)authorLegendProfile createdAt:(int64_t)createdAt raw:(NSString *)raw articleImageCdnImage:(PrimalSharedCdnImage * _Nullable)articleImageCdnImage articleReadingTimeInMinutes:(PrimalSharedInt * _Nullable)articleReadingTimeInMinutes __attribute__((swift_name("init(naddr:aTag:eventId:articleId:articleTitle:authorId:authorName:authorAvatarCdnImage:authorLegendProfile:createdAt:raw:articleImageCdnImage:articleReadingTimeInMinutes:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedReferencedArticle *)doCopyNaddr:(NSString *)naddr aTag:(NSString *)aTag eventId:(NSString *)eventId articleId:(NSString *)articleId articleTitle:(NSString *)articleTitle authorId:(NSString *)authorId authorName:(NSString *)authorName authorAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)authorAvatarCdnImage authorLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)authorLegendProfile createdAt:(int64_t)createdAt raw:(NSString *)raw articleImageCdnImage:(PrimalSharedCdnImage * _Nullable)articleImageCdnImage articleReadingTimeInMinutes:(PrimalSharedInt * _Nullable)articleReadingTimeInMinutes __attribute__((swift_name("doCopy(naddr:aTag:eventId:articleId:articleTitle:authorId:authorName:authorAvatarCdnImage:authorLegendProfile:createdAt:raw:articleImageCdnImage:articleReadingTimeInMinutes:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedArticle.Companion")))
@interface PrimalSharedReferencedArticleCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedReferencedArticleCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedHighlight")))
@interface PrimalSharedReferencedHighlight : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedReferencedHighlightCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *aTag __attribute__((swift_name("aTag")));
@property (readonly) NSString * _Nullable authorId __attribute__((swift_name("authorId")));
@property (readonly) NSString * _Nullable eventId __attribute__((swift_name("eventId")));
@property (readonly) NSString *text __attribute__((swift_name("text")));
- (instancetype)initWithText:(NSString *)text eventId:(NSString * _Nullable)eventId authorId:(NSString * _Nullable)authorId aTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)aTag __attribute__((swift_name("init(text:eventId:authorId:aTag:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedReferencedHighlight *)doCopyText:(NSString *)text eventId:(NSString * _Nullable)eventId authorId:(NSString * _Nullable)authorId aTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)aTag __attribute__((swift_name("doCopy(text:eventId:authorId:aTag:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedHighlight.Companion")))
@interface PrimalSharedReferencedHighlightCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedReferencedHighlightCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedNote")))
@interface PrimalSharedReferencedNote : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedReferencedNoteCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSArray<PrimalSharedEventLink *> *attachments __attribute__((swift_name("attachments")));
@property (readonly) PrimalSharedCdnImage * _Nullable authorAvatarCdnImage __attribute__((swift_name("authorAvatarCdnImage")));
@property (readonly) NSString *authorId __attribute__((swift_name("authorId")));
@property (readonly) NSString * _Nullable authorInternetIdentifier __attribute__((swift_name("authorInternetIdentifier")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable authorLegendProfile __attribute__((swift_name("authorLegendProfile")));
@property (readonly) NSString * _Nullable authorLightningAddress __attribute__((swift_name("authorLightningAddress")));
@property (readonly) NSString *authorName __attribute__((swift_name("authorName")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSArray<PrimalSharedEventUriNostrReference *> *nostrUris __attribute__((swift_name("nostrUris")));
@property (readonly) NSString *postId __attribute__((swift_name("postId")));
@property (readonly) NSString *raw __attribute__((swift_name("raw")));
- (instancetype)initWithPostId:(NSString *)postId createdAt:(int64_t)createdAt content:(NSString *)content authorId:(NSString *)authorId authorName:(NSString *)authorName authorAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)authorAvatarCdnImage authorInternetIdentifier:(NSString * _Nullable)authorInternetIdentifier authorLightningAddress:(NSString * _Nullable)authorLightningAddress authorLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)authorLegendProfile attachments:(NSArray<PrimalSharedEventLink *> *)attachments nostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)nostrUris raw:(NSString *)raw __attribute__((swift_name("init(postId:createdAt:content:authorId:authorName:authorAvatarCdnImage:authorInternetIdentifier:authorLightningAddress:authorLegendProfile:attachments:nostrUris:raw:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedReferencedNote *)doCopyPostId:(NSString *)postId createdAt:(int64_t)createdAt content:(NSString *)content authorId:(NSString *)authorId authorName:(NSString *)authorName authorAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)authorAvatarCdnImage authorInternetIdentifier:(NSString * _Nullable)authorInternetIdentifier authorLightningAddress:(NSString * _Nullable)authorLightningAddress authorLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)authorLegendProfile attachments:(NSArray<PrimalSharedEventLink *> *)attachments nostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)nostrUris raw:(NSString *)raw __attribute__((swift_name("doCopy(postId:createdAt:content:authorId:authorName:authorAvatarCdnImage:authorInternetIdentifier:authorLightningAddress:authorLegendProfile:attachments:nostrUris:raw:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedNote.Companion")))
@interface PrimalSharedReferencedNoteCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedReferencedNoteCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedUser")))
@interface PrimalSharedReferencedUser : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedReferencedUserCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *displayUsername __attribute__((swift_name("displayUsername")));
@property (readonly) NSString *handle __attribute__((swift_name("handle")));
@property (readonly) NSString *userId __attribute__((swift_name("userId")));
- (instancetype)initWithUserId:(NSString *)userId handle:(NSString *)handle __attribute__((swift_name("init(userId:handle:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedReferencedUser *)doCopyUserId:(NSString *)userId handle:(NSString *)handle __attribute__((swift_name("doCopy(userId:handle:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedUser.Companion")))
@interface PrimalSharedReferencedUserCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedReferencedUserCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedZap")))
@interface PrimalSharedReferencedZap : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedReferencedZapCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) double amountInSats __attribute__((swift_name("amountInSats")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString * _Nullable message __attribute__((swift_name("message")));
@property (readonly) PrimalSharedCdnImage * _Nullable receiverAvatarCdnImage __attribute__((swift_name("receiverAvatarCdnImage")));
@property (readonly) NSString * _Nullable receiverDisplayName __attribute__((swift_name("receiverDisplayName")));
@property (readonly) NSString *receiverId __attribute__((swift_name("receiverId")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable receiverPrimalLegendProfile __attribute__((swift_name("receiverPrimalLegendProfile")));
@property (readonly) PrimalSharedCdnImage * _Nullable senderAvatarCdnImage __attribute__((swift_name("senderAvatarCdnImage")));
@property (readonly) NSString *senderId __attribute__((swift_name("senderId")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable senderPrimalLegendProfile __attribute__((swift_name("senderPrimalLegendProfile")));
@property (readonly) NSString * _Nullable zappedEventContent __attribute__((swift_name("zappedEventContent")));
@property (readonly) NSArray<NSString *> *zappedEventHashtags __attribute__((swift_name("zappedEventHashtags")));
@property (readonly) NSString * _Nullable zappedEventId __attribute__((swift_name("zappedEventId")));
@property (readonly) NSArray<PrimalSharedEventUriNostrReference *> *zappedEventNostrUris __attribute__((swift_name("zappedEventNostrUris")));
- (instancetype)initWithSenderId:(NSString *)senderId senderAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)senderAvatarCdnImage senderPrimalLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)senderPrimalLegendProfile receiverId:(NSString *)receiverId receiverDisplayName:(NSString * _Nullable)receiverDisplayName receiverAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)receiverAvatarCdnImage receiverPrimalLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)receiverPrimalLegendProfile zappedEventId:(NSString * _Nullable)zappedEventId zappedEventContent:(NSString * _Nullable)zappedEventContent zappedEventNostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)zappedEventNostrUris zappedEventHashtags:(NSArray<NSString *> *)zappedEventHashtags amountInSats:(double)amountInSats message:(NSString * _Nullable)message createdAt:(int64_t)createdAt __attribute__((swift_name("init(senderId:senderAvatarCdnImage:senderPrimalLegendProfile:receiverId:receiverDisplayName:receiverAvatarCdnImage:receiverPrimalLegendProfile:zappedEventId:zappedEventContent:zappedEventNostrUris:zappedEventHashtags:amountInSats:message:createdAt:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedReferencedZap *)doCopySenderId:(NSString *)senderId senderAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)senderAvatarCdnImage senderPrimalLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)senderPrimalLegendProfile receiverId:(NSString *)receiverId receiverDisplayName:(NSString * _Nullable)receiverDisplayName receiverAvatarCdnImage:(PrimalSharedCdnImage * _Nullable)receiverAvatarCdnImage receiverPrimalLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)receiverPrimalLegendProfile zappedEventId:(NSString * _Nullable)zappedEventId zappedEventContent:(NSString * _Nullable)zappedEventContent zappedEventNostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)zappedEventNostrUris zappedEventHashtags:(NSArray<NSString *> *)zappedEventHashtags amountInSats:(double)amountInSats message:(NSString * _Nullable)message createdAt:(int64_t)createdAt __attribute__((swift_name("doCopy(senderId:senderAvatarCdnImage:senderPrimalLegendProfile:receiverId:receiverDisplayName:receiverAvatarCdnImage:receiverPrimalLegendProfile:zappedEventId:zappedEventContent:zappedEventNostrUris:zappedEventHashtags:amountInSats:message:createdAt:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReferencedZap.Companion")))
@interface PrimalSharedReferencedZapCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedReferencedZapCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("ChatRepository")))
@protocol PrimalSharedChatRepository
@required

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchFollowConversationsUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchFollowConversations(userId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchNewConversationMessagesUserId:(NSString *)userId conversationUserId:(NSString *)conversationUserId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchNewConversationMessages(userId:conversationUserId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchNonFollowsConversationsUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchNonFollowsConversations(userId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)markAllMessagesAsReadAuthorization:(PrimalSharedNostrEvent *)authorization completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("markAllMessagesAsRead(authorization:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)markConversationAsReadAuthorization:(PrimalSharedNostrEvent *)authorization conversationUserId:(NSString *)conversationUserId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("markConversationAsRead(authorization:conversationUserId:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)newestConversationsUserId:(NSString *)userId relation:(PrimalSharedConversationRelation *)relation __attribute__((swift_name("newestConversations(userId:relation:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)newestMessagesUserId:(NSString *)userId participantId:(NSString *)participantId __attribute__((swift_name("newestMessages(userId:participantId:)")));

/**
 * @note This method converts instances of MessageEncryptException, NostrPublishException, SignatureException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)sendMessageUserId:(NSString *)userId receiverId:(NSString *)receiverId text:(NSString *)text completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("sendMessage(userId:receiverId:text:completionHandler:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ConversationRelation")))
@interface PrimalSharedConversationRelation : PrimalSharedKotlinEnum<PrimalSharedConversationRelation *>
@property (class, readonly, getter=companion) PrimalSharedConversationRelationCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) PrimalSharedConversationRelation *follows __attribute__((swift_name("follows")));
@property (class, readonly) PrimalSharedConversationRelation *other __attribute__((swift_name("other")));
@property (class, readonly) NSArray<PrimalSharedConversationRelation *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedConversationRelation *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ConversationRelation.Companion")))
@interface PrimalSharedConversationRelationCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedConversationRelationCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializerTypeParamsSerializers:(PrimalSharedKotlinArray<id<PrimalSharedKotlinx_serialization_coreKSerializer>> *)typeParamsSerializers __attribute__((swift_name("serializer(typeParamsSerializers:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DMConversation")))
@interface PrimalSharedDMConversation : PrimalSharedBase
@property (readonly) PrimalSharedDirectMessage * _Nullable lastMessage __attribute__((swift_name("lastMessage")));
@property (readonly) NSString *ownerId __attribute__((swift_name("ownerId")));
@property (readonly) PrimalSharedProfileData *participant __attribute__((swift_name("participant")));
@property (readonly) PrimalSharedConversationRelation *relation __attribute__((swift_name("relation")));
@property (readonly) int32_t unreadMessagesCount __attribute__((swift_name("unreadMessagesCount")));
- (instancetype)initWithOwnerId:(NSString *)ownerId participant:(PrimalSharedProfileData *)participant lastMessage:(PrimalSharedDirectMessage * _Nullable)lastMessage unreadMessagesCount:(int32_t)unreadMessagesCount relation:(PrimalSharedConversationRelation *)relation __attribute__((swift_name("init(ownerId:participant:lastMessage:unreadMessagesCount:relation:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedDMConversation *)doCopyOwnerId:(NSString *)ownerId participant:(PrimalSharedProfileData *)participant lastMessage:(PrimalSharedDirectMessage * _Nullable)lastMessage unreadMessagesCount:(int32_t)unreadMessagesCount relation:(PrimalSharedConversationRelation *)relation __attribute__((swift_name("doCopy(ownerId:participant:lastMessage:unreadMessagesCount:relation:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("DirectMessage")))
@interface PrimalSharedDirectMessage : PrimalSharedBase
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSArray<NSString *> *hashtags __attribute__((swift_name("hashtags")));
@property (readonly) NSArray<PrimalSharedEventLink *> *links __attribute__((swift_name("links")));
@property (readonly) NSString *messageId __attribute__((swift_name("messageId")));
@property (readonly) NSArray<PrimalSharedEventUriNostrReference *> *nostrUris __attribute__((swift_name("nostrUris")));
@property (readonly) NSString *ownerId __attribute__((swift_name("ownerId")));
@property (readonly) NSString *participantId __attribute__((swift_name("participantId")));
@property (readonly) NSString *receiverId __attribute__((swift_name("receiverId")));
@property (readonly) NSString *senderId __attribute__((swift_name("senderId")));
- (instancetype)initWithMessageId:(NSString *)messageId ownerId:(NSString *)ownerId senderId:(NSString *)senderId receiverId:(NSString *)receiverId participantId:(NSString *)participantId createdAt:(int64_t)createdAt content:(NSString *)content hashtags:(NSArray<NSString *> *)hashtags links:(NSArray<PrimalSharedEventLink *> *)links nostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)nostrUris __attribute__((swift_name("init(messageId:ownerId:senderId:receiverId:participantId:createdAt:content:hashtags:links:nostrUris:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedDirectMessage *)doCopyMessageId:(NSString *)messageId ownerId:(NSString *)ownerId senderId:(NSString *)senderId receiverId:(NSString *)receiverId participantId:(NSString *)participantId createdAt:(int64_t)createdAt content:(NSString *)content hashtags:(NSArray<NSString *> *)hashtags links:(NSArray<PrimalSharedEventLink *> *)links nostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)nostrUris __attribute__((swift_name("doCopy(messageId:ownerId:senderId:receiverId:participantId:createdAt:content:hashtags:links:nostrUris:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("MutedItemRepository")))
@protocol PrimalSharedMutedItemRepository
@required

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchAndPersistMuteListUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchAndPersistMuteList(userId:completionHandler:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)muteHashtagAndPersistMuteListUserId:(NSString *)userId hashtag:(NSString *)hashtag completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("muteHashtagAndPersistMuteList(userId:hashtag:completionHandler:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)muteThreadAndPersistMuteListUserId:(NSString *)userId postId:(NSString *)postId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("muteThreadAndPersistMuteList(userId:postId:completionHandler:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)muteUserAndPersistMuteListUserId:(NSString *)userId mutedUserId:(NSString *)mutedUserId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("muteUserAndPersistMuteList(userId:mutedUserId:completionHandler:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)muteWordAndPersistMuteListUserId:(NSString *)userId word:(NSString *)word completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("muteWordAndPersistMuteList(userId:word:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeIsUserMutedByOwnerIdPubkey:(NSString *)pubkey ownerId:(NSString *)ownerId __attribute__((swift_name("observeIsUserMutedByOwnerId(pubkey:ownerId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeMutedHashtagsByOwnerIdOwnerId:(NSString *)ownerId __attribute__((swift_name("observeMutedHashtagsByOwnerId(ownerId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeMutedProfileIdsByOwnerIdOwnerId:(NSString *)ownerId __attribute__((swift_name("observeMutedProfileIdsByOwnerId(ownerId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeMutedUsersByOwnerIdOwnerId:(NSString *)ownerId __attribute__((swift_name("observeMutedUsersByOwnerId(ownerId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeMutedWordsByOwnerIdOwnerId:(NSString *)ownerId __attribute__((swift_name("observeMutedWordsByOwnerId(ownerId:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)unmuteHashtagAndPersistMuteListUserId:(NSString *)userId hashtag:(NSString *)hashtag completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("unmuteHashtagAndPersistMuteList(userId:hashtag:completionHandler:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)unmuteThreadAndPersistMuteListUserId:(NSString *)userId postId:(NSString *)postId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("unmuteThreadAndPersistMuteList(userId:postId:completionHandler:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)unmuteUserAndPersistMuteListUserId:(NSString *)userId unmutedUserId:(NSString *)unmutedUserId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("unmuteUserAndPersistMuteList(userId:unmutedUserId:completionHandler:)")));

/**
 * @note This method converts instances of MissingRelaysException, NostrPublishException, SignatureException, CancellationException, NetworkException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)unmuteWordAndPersistMuteListUserId:(NSString *)userId word:(NSString *)word completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("unmuteWordAndPersistMuteList(userId:word:completionHandler:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentMetadata")))
@interface PrimalSharedContentMetadata : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedContentMetadataCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString * _Nullable about __attribute__((swift_name("about")));
@property (readonly) NSString * _Nullable banner __attribute__((swift_name("banner")));
@property (readonly) NSString * _Nullable displayName __attribute__((swift_name("displayName")));
@property (readonly) NSString * _Nullable lud06 __attribute__((swift_name("lud06")));
@property (readonly) NSString * _Nullable lud16 __attribute__((swift_name("lud16")));
@property (readonly) NSString * _Nullable name __attribute__((swift_name("name")));
@property (readonly) NSString * _Nullable nip05 __attribute__((swift_name("nip05")));
@property (readonly) NSString * _Nullable picture __attribute__((swift_name("picture")));
@property (readonly) NSString * _Nullable website __attribute__((swift_name("website")));
- (instancetype)initWithName:(NSString * _Nullable)name nip05:(NSString * _Nullable)nip05 about:(NSString * _Nullable)about lud06:(NSString * _Nullable)lud06 lud16:(NSString * _Nullable)lud16 displayName:(NSString * _Nullable)displayName picture:(NSString * _Nullable)picture banner:(NSString * _Nullable)banner website:(NSString * _Nullable)website __attribute__((swift_name("init(name:nip05:about:lud06:lud16:displayName:picture:banner:website:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedContentMetadata *)doCopyName:(NSString * _Nullable)name nip05:(NSString * _Nullable)nip05 about:(NSString * _Nullable)about lud06:(NSString * _Nullable)lud06 lud16:(NSString * _Nullable)lud16 displayName:(NSString * _Nullable)displayName picture:(NSString * _Nullable)picture banner:(NSString * _Nullable)banner website:(NSString * _Nullable)website __attribute__((swift_name("doCopy(name:nip05:about:lud06:lud16:displayName:picture:banner:website:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="display_name")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentMetadata.Companion")))
@interface PrimalSharedContentMetadataCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedContentMetadataCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Naddr")))
@interface PrimalSharedNaddr : PrimalSharedBase
@property (readonly) NSString *identifier __attribute__((swift_name("identifier")));
@property (readonly) int32_t kind __attribute__((swift_name("kind")));
@property (readonly) NSArray<NSString *> *relays __attribute__((swift_name("relays")));
@property (readonly) NSString *userId __attribute__((swift_name("userId")));
- (instancetype)initWithKind:(int32_t)kind userId:(NSString *)userId identifier:(NSString *)identifier relays:(NSArray<NSString *> *)relays __attribute__((swift_name("init(kind:userId:identifier:relays:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNaddr *)doCopyKind:(int32_t)kind userId:(NSString *)userId identifier:(NSString *)identifier relays:(NSArray<NSString *> *)relays __attribute__((swift_name("doCopy(kind:userId:identifier:relays:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Nevent")))
@interface PrimalSharedNevent : PrimalSharedBase
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) PrimalSharedInt * _Nullable kind __attribute__((swift_name("kind")));
@property (readonly) NSArray<NSString *> *relays __attribute__((swift_name("relays")));
@property (readonly) NSString * _Nullable userId __attribute__((swift_name("userId")));
- (instancetype)initWithEventId:(NSString *)eventId kind:(PrimalSharedInt * _Nullable)kind userId:(NSString * _Nullable)userId relays:(NSArray<NSString *> *)relays __attribute__((swift_name("init(eventId:kind:userId:relays:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNevent *)doCopyEventId:(NSString *)eventId kind:(PrimalSharedInt * _Nullable)kind userId:(NSString * _Nullable)userId relays:(NSArray<NSString *> *)relays __attribute__((swift_name("doCopy(eventId:kind:userId:relays:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Nip19TLV")))
@interface PrimalSharedNip19TLV : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNip19TLV *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)nip19TLV __attribute__((swift_name("init()")));
- (PrimalSharedKotlinByteArray *)hexToBytes:(NSString *)receiver __attribute__((swift_name("hexToBytes(_:)")));
- (NSDictionary<PrimalSharedByte *, NSArray<PrimalSharedKotlinByteArray *> *> *)parseData:(PrimalSharedKotlinByteArray *)data __attribute__((swift_name("parse(data:)")));

/**
 * @note This method converts instances of IllegalArgumentException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (NSDictionary<PrimalSharedByte *, NSArray<PrimalSharedKotlinByteArray *> *> * _Nullable)parseData:(NSString *)data error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("parse(data_:)")));
- (PrimalSharedNaddr * _Nullable)parseUriAsNaddrOrNullNaddrUri:(NSString *)naddrUri __attribute__((swift_name("parseUriAsNaddrOrNull(naddrUri:)")));
- (PrimalSharedNevent * _Nullable)parseUriAsNeventOrNullNeventUri:(NSString *)neventUri __attribute__((swift_name("parseUriAsNeventOrNull(neventUri:)")));
- (PrimalSharedNprofile * _Nullable)parseUriAsNprofileOrNullNprofileUri:(NSString *)nprofileUri __attribute__((swift_name("parseUriAsNprofileOrNull(nprofileUri:)")));
- (NSString *)readAsString:(PrimalSharedKotlinByteArray *)receiver __attribute__((swift_name("readAsString(_:)")));
- (int32_t)toInt32Bytes:(PrimalSharedKotlinByteArray *)bytes __attribute__((swift_name("toInt32(bytes:)")));
- (NSString *)toNaddrString:(PrimalSharedNaddr *)receiver __attribute__((swift_name("toNaddrString(_:)")));
- (NSString *)toNeventString:(PrimalSharedNevent *)receiver __attribute__((swift_name("toNeventString(_:)")));
- (NSString *)toNprofileString:(PrimalSharedNprofile *)receiver __attribute__((swift_name("toNprofileString(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Nip19TLV.Type_")))
@interface PrimalSharedNip19TLVType : PrimalSharedKotlinEnum<PrimalSharedNip19TLVType *>
@property (class, readonly) PrimalSharedNip19TLVType *special __attribute__((swift_name("special")));
@property (class, readonly) PrimalSharedNip19TLVType *relay __attribute__((swift_name("relay")));
@property (class, readonly) PrimalSharedNip19TLVType *author __attribute__((swift_name("author")));
@property (class, readonly) PrimalSharedNip19TLVType *kind __attribute__((swift_name("kind")));
@property (class, readonly) NSArray<PrimalSharedNip19TLVType *> *entries __attribute__((swift_name("entries")));
@property (readonly) int8_t id __attribute__((swift_name("id")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedNip19TLVType *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Nip94Metadata")))
@interface PrimalSharedNip94Metadata : PrimalSharedBase
@property (readonly) NSString * _Nullable alt __attribute__((swift_name("alt")));
@property (readonly) NSString * _Nullable blurhash __attribute__((swift_name("blurhash")));
@property (readonly) NSString * _Nullable dim __attribute__((swift_name("dim")));
@property (readonly) NSString * _Nullable fallback __attribute__((swift_name("fallback")));
@property (readonly) NSString * _Nullable i __attribute__((swift_name("i")));
@property (readonly) NSString * _Nullable image __attribute__((swift_name("image")));
@property (readonly) NSString * _Nullable m __attribute__((swift_name("m")));
@property (readonly) NSString * _Nullable magnet __attribute__((swift_name("magnet")));
@property (readonly) NSString * _Nullable ox __attribute__((swift_name("ox")));
@property (readonly) NSString * _Nullable service __attribute__((swift_name("service")));
@property (readonly) PrimalSharedLong * _Nullable size __attribute__((swift_name("size")));
@property (readonly) NSString * _Nullable summary __attribute__((swift_name("summary")));
@property (readonly) NSString * _Nullable thumb __attribute__((swift_name("thumb")));
@property (readonly) NSString * _Nullable url __attribute__((swift_name("url")));
@property (readonly) NSString * _Nullable x __attribute__((swift_name("x")));
- (instancetype)initWithUrl:(NSString * _Nullable)url m:(NSString * _Nullable)m x:(NSString * _Nullable)x ox:(NSString * _Nullable)ox size:(PrimalSharedLong * _Nullable)size dim:(NSString * _Nullable)dim magnet:(NSString * _Nullable)magnet i:(NSString * _Nullable)i blurhash:(NSString * _Nullable)blurhash thumb:(NSString * _Nullable)thumb image:(NSString * _Nullable)image summary:(NSString * _Nullable)summary alt:(NSString * _Nullable)alt fallback:(NSString * _Nullable)fallback service:(NSString * _Nullable)service __attribute__((swift_name("init(url:m:x:ox:size:dim:magnet:i:blurhash:thumb:image:summary:alt:fallback:service:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNip94Metadata *)doCopyUrl:(NSString * _Nullable)url m:(NSString * _Nullable)m x:(NSString * _Nullable)x ox:(NSString * _Nullable)ox size:(PrimalSharedLong * _Nullable)size dim:(NSString * _Nullable)dim magnet:(NSString * _Nullable)magnet i:(NSString * _Nullable)i blurhash:(NSString * _Nullable)blurhash thumb:(NSString * _Nullable)thumb image:(NSString * _Nullable)image summary:(NSString * _Nullable)summary alt:(NSString * _Nullable)alt fallback:(NSString * _Nullable)fallback service:(NSString * _Nullable)service __attribute__((swift_name("doCopy(url:m:x:ox:size:dim:magnet:i:blurhash:thumb:image:summary:alt:fallback:service:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEvent")))
@interface PrimalSharedNostrEvent : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedNostrEventCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) int32_t kind __attribute__((swift_name("kind")));
@property (readonly) NSString *pubKey __attribute__((swift_name("pubKey")));
@property (readonly) NSString *sig __attribute__((swift_name("sig")));
@property (readonly) NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *tags __attribute__((swift_name("tags")));
- (instancetype)initWithId:(NSString *)id pubKey:(NSString *)pubKey createdAt:(int64_t)createdAt kind:(int32_t)kind tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags content:(NSString *)content sig:(NSString *)sig __attribute__((swift_name("init(id:pubKey:createdAt:kind:tags:content:sig:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrEvent *)doCopyId:(NSString *)id pubKey:(NSString *)pubKey createdAt:(int64_t)createdAt kind:(int32_t)kind tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags content:(NSString *)content sig:(NSString *)sig __attribute__((swift_name("doCopy(id:pubKey:createdAt:kind:tags:content:sig:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="created_at")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="pubkey")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEvent.Companion")))
@interface PrimalSharedNostrEventCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrEventCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEventKind")))
@interface PrimalSharedNostrEventKind : PrimalSharedKotlinEnum<PrimalSharedNostrEventKind *>
@property (class, readonly, getter=companion) PrimalSharedNostrEventKindCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) PrimalSharedNostrEventKind *metadata __attribute__((swift_name("metadata")));
@property (class, readonly) PrimalSharedNostrEventKind *shorttextnote __attribute__((swift_name("shorttextnote")));
@property (class, readonly) PrimalSharedNostrEventKind *recommendrelay __attribute__((swift_name("recommendrelay")));
@property (class, readonly) PrimalSharedNostrEventKind *followlist __attribute__((swift_name("followlist")));
@property (class, readonly) PrimalSharedNostrEventKind *encrypteddirectmessages __attribute__((swift_name("encrypteddirectmessages")));
@property (class, readonly) PrimalSharedNostrEventKind *eventdeletion __attribute__((swift_name("eventdeletion")));
@property (class, readonly) PrimalSharedNostrEventKind *shorttextnoterepost __attribute__((swift_name("shorttextnoterepost")));
@property (class, readonly) PrimalSharedNostrEventKind *reaction __attribute__((swift_name("reaction")));
@property (class, readonly) PrimalSharedNostrEventKind *badgeaward __attribute__((swift_name("badgeaward")));
@property (class, readonly) PrimalSharedNostrEventKind *genericrepost __attribute__((swift_name("genericrepost")));
@property (class, readonly) PrimalSharedNostrEventKind *picturenote __attribute__((swift_name("picturenote")));
@property (class, readonly) PrimalSharedNostrEventKind *channelcreation __attribute__((swift_name("channelcreation")));
@property (class, readonly) PrimalSharedNostrEventKind *channelmetadata __attribute__((swift_name("channelmetadata")));
@property (class, readonly) PrimalSharedNostrEventKind *channelmessage __attribute__((swift_name("channelmessage")));
@property (class, readonly) PrimalSharedNostrEventKind *channelhidemessage __attribute__((swift_name("channelhidemessage")));
@property (class, readonly) PrimalSharedNostrEventKind *channelmuteuser __attribute__((swift_name("channelmuteuser")));
@property (class, readonly) PrimalSharedNostrEventKind *filemetadata __attribute__((swift_name("filemetadata")));
@property (class, readonly) PrimalSharedNostrEventKind *reporting __attribute__((swift_name("reporting")));
@property (class, readonly) PrimalSharedNostrEventKind *zaprequest __attribute__((swift_name("zaprequest")));
@property (class, readonly) PrimalSharedNostrEventKind *zap __attribute__((swift_name("zap")));
@property (class, readonly) PrimalSharedNostrEventKind *highlight __attribute__((swift_name("highlight")));
@property (class, readonly) PrimalSharedNostrEventKind *mutelist __attribute__((swift_name("mutelist")));
@property (class, readonly) PrimalSharedNostrEventKind *pinlist __attribute__((swift_name("pinlist")));
@property (class, readonly) PrimalSharedNostrEventKind *relaylistmetadata __attribute__((swift_name("relaylistmetadata")));
@property (class, readonly) PrimalSharedNostrEventKind *bookmarkslist __attribute__((swift_name("bookmarkslist")));
@property (class, readonly) PrimalSharedNostrEventKind *blossomserverlist __attribute__((swift_name("blossomserverlist")));
@property (class, readonly) PrimalSharedNostrEventKind *walletinfo __attribute__((swift_name("walletinfo")));
@property (class, readonly) PrimalSharedNostrEventKind *clientauthentication __attribute__((swift_name("clientauthentication")));
@property (class, readonly) PrimalSharedNostrEventKind *nwcrequest __attribute__((swift_name("nwcrequest")));
@property (class, readonly) PrimalSharedNostrEventKind *nwcresponse __attribute__((swift_name("nwcresponse")));
@property (class, readonly) PrimalSharedNostrEventKind *nostrconnect __attribute__((swift_name("nostrconnect")));
@property (class, readonly) PrimalSharedNostrEventKind *blossomuploadblob __attribute__((swift_name("blossomuploadblob")));
@property (class, readonly) PrimalSharedNostrEventKind *categorizedpeoplelist __attribute__((swift_name("categorizedpeoplelist")));
@property (class, readonly) PrimalSharedNostrEventKind *categorizedbookmarklist __attribute__((swift_name("categorizedbookmarklist")));
@property (class, readonly) PrimalSharedNostrEventKind *profilebadges __attribute__((swift_name("profilebadges")));
@property (class, readonly) PrimalSharedNostrEventKind *badgedefinition __attribute__((swift_name("badgedefinition")));
@property (class, readonly) PrimalSharedNostrEventKind *longformcontent __attribute__((swift_name("longformcontent")));
@property (class, readonly) PrimalSharedNostrEventKind *applicationspecificdata __attribute__((swift_name("applicationspecificdata")));
@property (class, readonly) PrimalSharedNostrEventKind *apprecommendation __attribute__((swift_name("apprecommendation")));
@property (class, readonly) PrimalSharedNostrEventKind *apphandler __attribute__((swift_name("apphandler")));
@property (class, readonly) PrimalSharedNostrEventKind *starterpack __attribute__((swift_name("starterpack")));
@property (class, readonly) PrimalSharedNostrEventKind *primaleventstats __attribute__((swift_name("primaleventstats")));
@property (class, readonly) PrimalSharedNostrEventKind *primalnetstats __attribute__((swift_name("primalnetstats")));
@property (class, readonly) PrimalSharedNostrEventKind *primalexplorelegendcounts __attribute__((swift_name("primalexplorelegendcounts")));
@property (class, readonly) PrimalSharedNostrEventKind *primaldefaultsettings __attribute__((swift_name("primaldefaultsettings")));
@property (class, readonly) PrimalSharedNostrEventKind *primaluserprofilestats __attribute__((swift_name("primaluserprofilestats")));
@property (class, readonly) PrimalSharedNostrEventKind *primalreferencedevent __attribute__((swift_name("primalreferencedevent")));
@property (class, readonly) PrimalSharedNostrEventKind *primaluserscores __attribute__((swift_name("primaluserscores")));
@property (class, readonly) PrimalSharedNostrEventKind *primalrelays __attribute__((swift_name("primalrelays")));
@property (class, readonly) PrimalSharedNostrEventKind *primalnotification __attribute__((swift_name("primalnotification")));
@property (class, readonly) PrimalSharedNostrEventKind *primalnotificationsseenuntil __attribute__((swift_name("primalnotificationsseenuntil")));
@property (class, readonly) PrimalSharedNostrEventKind *primalpaging __attribute__((swift_name("primalpaging")));
@property (class, readonly) PrimalSharedNostrEventKind *primalmediamapping __attribute__((swift_name("primalmediamapping")));
@property (class, readonly) PrimalSharedNostrEventKind *primaleventuserstats __attribute__((swift_name("primaleventuserstats")));
@property (class, readonly) PrimalSharedNostrEventKind *primaldirectmessagesconversationssummary __attribute__((swift_name("primaldirectmessagesconversationssummary")));
@property (class, readonly) PrimalSharedNostrEventKind *primalcdnresource __attribute__((swift_name("primalcdnresource")));
@property (class, readonly) PrimalSharedNostrEventKind *primalsimpleuploadrequest __attribute__((swift_name("primalsimpleuploadrequest")));
@property (class, readonly) PrimalSharedNostrEventKind *primaluploadresponse __attribute__((swift_name("primaluploadresponse")));
@property (class, readonly) PrimalSharedNostrEventKind *primaldefaultrelayslist __attribute__((swift_name("primaldefaultrelayslist")));
@property (class, readonly) PrimalSharedNostrEventKind *primalisuserfollowing __attribute__((swift_name("primalisuserfollowing")));
@property (class, readonly) PrimalSharedNostrEventKind *primallinkpreview __attribute__((swift_name("primallinkpreview")));
@property (class, readonly) PrimalSharedNostrEventKind *primalnotificationssummary2 __attribute__((swift_name("primalnotificationssummary2")));
@property (class, readonly) PrimalSharedNostrEventKind *primaluserfollowerscounts __attribute__((swift_name("primaluserfollowerscounts")));
@property (class, readonly) PrimalSharedNostrEventKind *primaldirectmessagesunreadcount2 __attribute__((swift_name("primaldirectmessagesunreadcount2")));
@property (class, readonly) PrimalSharedNostrEventKind *primalchunkeduploadrequest __attribute__((swift_name("primalchunkeduploadrequest")));
@property (class, readonly) PrimalSharedNostrEventKind *primaluserrelayslist __attribute__((swift_name("primaluserrelayslist")));
@property (class, readonly) PrimalSharedNostrEventKind *primalrelayhint __attribute__((swift_name("primalrelayhint")));
@property (class, readonly) PrimalSharedNostrEventKind *primallongformwordscount __attribute__((swift_name("primallongformwordscount")));
@property (class, readonly) PrimalSharedNostrEventKind *primalbroadcastresult __attribute__((swift_name("primalbroadcastresult")));
@property (class, readonly) PrimalSharedNostrEventKind *primallongformcontentfeeds __attribute__((swift_name("primallongformcontentfeeds")));
@property (class, readonly) PrimalSharedNostrEventKind *primalsubsettings __attribute__((swift_name("primalsubsettings")));
@property (class, readonly) PrimalSharedNostrEventKind *primaldvmfeedfollowsactions __attribute__((swift_name("primaldvmfeedfollowsactions")));
@property (class, readonly) PrimalSharedNostrEventKind *primalexplorepeoplenewfollowstats __attribute__((swift_name("primalexplorepeoplenewfollowstats")));
@property (class, readonly) PrimalSharedNostrEventKind *primalusernames __attribute__((swift_name("primalusernames")));
@property (class, readonly) PrimalSharedNostrEventKind *primaldvmfeedmetadata __attribute__((swift_name("primaldvmfeedmetadata")));
@property (class, readonly) PrimalSharedNostrEventKind *primaltrendingtopics __attribute__((swift_name("primaltrendingtopics")));
@property (class, readonly) PrimalSharedNostrEventKind *primalclientconfig __attribute__((swift_name("primalclientconfig")));
@property (class, readonly) PrimalSharedNostrEventKind *primalusermediastoragestats __attribute__((swift_name("primalusermediastoragestats")));
@property (class, readonly) PrimalSharedNostrEventKind *primaluseruploadinfo __attribute__((swift_name("primaluseruploadinfo")));
@property (class, readonly) PrimalSharedNostrEventKind *primalcontentbroadcaststats __attribute__((swift_name("primalcontentbroadcaststats")));
@property (class, readonly) PrimalSharedNostrEventKind *primalcontentbroadcaststatus __attribute__((swift_name("primalcontentbroadcaststatus")));
@property (class, readonly) PrimalSharedNostrEventKind *primallegendprofiles __attribute__((swift_name("primallegendprofiles")));
@property (class, readonly) PrimalSharedNostrEventKind *primalpremiuminfo __attribute__((swift_name("primalpremiuminfo")));
@property (class, readonly) PrimalSharedNostrEventKind *primallegendleaderboard __attribute__((swift_name("primallegendleaderboard")));
@property (class, readonly) PrimalSharedNostrEventKind *primalpremiumleaderboard __attribute__((swift_name("primalpremiumleaderboard")));
@property (class, readonly) PrimalSharedNostrEventKind *primalrecommendedblossomserver __attribute__((swift_name("primalrecommendedblossomserver")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletoperation __attribute__((swift_name("primalwalletoperation")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletbalance __attribute__((swift_name("primalwalletbalance")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletdepositinvoice __attribute__((swift_name("primalwalletdepositinvoice")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletdepositlnurl __attribute__((swift_name("primalwalletdepositlnurl")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwallettransactions __attribute__((swift_name("primalwallettransactions")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletexchangerate __attribute__((swift_name("primalwalletexchangerate")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletisuser __attribute__((swift_name("primalwalletisuser")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletuserinfo __attribute__((swift_name("primalwalletuserinfo")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletinapppurchasequote __attribute__((swift_name("primalwalletinapppurchasequote")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletinapppurchase __attribute__((swift_name("primalwalletinapppurchase")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletactivation __attribute__((swift_name("primalwalletactivation")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletparsedlnurl __attribute__((swift_name("primalwalletparsedlnurl")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletparsedlninvoice __attribute__((swift_name("primalwalletparsedlninvoice")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletminingfees __attribute__((swift_name("primalwalletminingfees")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletonchainaddress __attribute__((swift_name("primalwalletonchainaddress")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletupdatedat __attribute__((swift_name("primalwalletupdatedat")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletnwcconnectioncreated __attribute__((swift_name("primalwalletnwcconnectioncreated")));
@property (class, readonly) PrimalSharedNostrEventKind *primalwalletnwcconnectionlist __attribute__((swift_name("primalwalletnwcconnectionlist")));
@property (class, readonly) PrimalSharedNostrEventKind *primalmembershipnameavailable __attribute__((swift_name("primalmembershipnameavailable")));
@property (class, readonly) PrimalSharedNostrEventKind *primalmembershiplegendpaymentinstructions __attribute__((swift_name("primalmembershiplegendpaymentinstructions")));
@property (class, readonly) PrimalSharedNostrEventKind *primalmembershippurchasemonitor __attribute__((swift_name("primalmembershippurchasemonitor")));
@property (class, readonly) PrimalSharedNostrEventKind *primalmembershipstatus __attribute__((swift_name("primalmembershipstatus")));
@property (class, readonly) PrimalSharedNostrEventKind *primalmembershiphistory __attribute__((swift_name("primalmembershiphistory")));
@property (class, readonly) PrimalSharedNostrEventKind *primalpromocodedetails __attribute__((swift_name("primalpromocodedetails")));
@property (class, readonly) PrimalSharedNostrEventKind *primalappstate __attribute__((swift_name("primalappstate")));
@property (class, readonly) PrimalSharedNostrEventKind *primallongformcontent __attribute__((swift_name("primallongformcontent")));
@property (class, readonly) PrimalSharedNostrEventKind *unknown __attribute__((swift_name("unknown")));
@property (class, readonly) NSArray<PrimalSharedNostrEventKind *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t value_ __attribute__((swift_name("value_")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedNostrEventKind *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEventKind.Companion")))
@interface PrimalSharedNostrEventKindCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrEventKindCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializerTypeParamsSerializers:(PrimalSharedKotlinArray<id<PrimalSharedKotlinx_serialization_coreKSerializer>> *)typeParamsSerializers __attribute__((swift_name("serializer(typeParamsSerializers:)")));
- (PrimalSharedNostrEventKind *)valueOfValue:(int32_t)value __attribute__((swift_name("valueOf(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEventKindRange")))
@interface PrimalSharedNostrEventKindRange : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrEventKindRange *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKotlinIntRange *EphemeralEvents __attribute__((swift_name("EphemeralEvents")));
@property (readonly) PrimalSharedKotlinIntRange *ParameterizedReplaceableEvents __attribute__((swift_name("ParameterizedReplaceableEvents")));
@property (readonly) PrimalSharedKotlinIntRange *PrimalEvents __attribute__((swift_name("PrimalEvents")));
@property (readonly) PrimalSharedKotlinIntRange *RegularEvents __attribute__((swift_name("RegularEvents")));
@property (readonly) PrimalSharedKotlinIntRange *ReplaceableEvents __attribute__((swift_name("ReplaceableEvents")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)nostrEventKindRange __attribute__((swift_name("init()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrUnsignedEvent")))
@interface PrimalSharedNostrUnsignedEvent : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedNostrUnsignedEventCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) int32_t kind __attribute__((swift_name("kind")));
@property (readonly) NSString *pubKey __attribute__((swift_name("pubKey")));
@property (readonly) NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *tags __attribute__((swift_name("tags")));
- (instancetype)initWithPubKey:(NSString *)pubKey createdAt:(int64_t)createdAt tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags kind:(int32_t)kind content:(NSString *)content __attribute__((swift_name("init(pubKey:createdAt:tags:kind:content:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrUnsignedEvent *)doCopyPubKey:(NSString *)pubKey createdAt:(int64_t)createdAt tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags kind:(int32_t)kind content:(NSString *)content __attribute__((swift_name("doCopy(pubKey:createdAt:tags:kind:content:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="created_at")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="pubkey")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrUnsignedEvent.Companion")))
@interface PrimalSharedNostrUnsignedEventCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNostrUnsignedEventCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Nprofile")))
@interface PrimalSharedNprofile : PrimalSharedBase
@property (readonly) NSString *pubkey __attribute__((swift_name("pubkey")));
@property (readonly) NSArray<NSString *> *relays __attribute__((swift_name("relays")));
- (instancetype)initWithPubkey:(NSString *)pubkey relays:(NSArray<NSString *> *)relays __attribute__((swift_name("init(pubkey:relays:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNprofile *)doCopyPubkey:(NSString *)pubkey relays:(NSArray<NSString *> *)relays __attribute__((swift_name("doCopy(pubkey:relays:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PublicBookmarksNotFoundException")))
@interface PrimalSharedPublicBookmarksNotFoundException : PrimalSharedKotlinException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReactionType")))
@interface PrimalSharedReactionType : PrimalSharedKotlinEnum<PrimalSharedReactionType *>
@property (class, readonly) PrimalSharedReactionType *zaps __attribute__((swift_name("zaps")));
@property (class, readonly) PrimalSharedReactionType *likes __attribute__((swift_name("likes")));
@property (class, readonly) PrimalSharedReactionType *reposts __attribute__((swift_name("reposts")));
@property (class, readonly) PrimalSharedReactionType *replies __attribute__((swift_name("replies")));
@property (class, readonly) NSArray<PrimalSharedReactionType *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedReactionType *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ReportType")))
@interface PrimalSharedReportType : PrimalSharedKotlinEnum<PrimalSharedReportType *>
@property (class, readonly) PrimalSharedReportType *nudity __attribute__((swift_name("nudity")));
@property (class, readonly) PrimalSharedReportType *profanity __attribute__((swift_name("profanity")));
@property (class, readonly) PrimalSharedReportType *illegal __attribute__((swift_name("illegal")));
@property (class, readonly) PrimalSharedReportType *spam __attribute__((swift_name("spam")));
@property (class, readonly) PrimalSharedReportType *impersonation __attribute__((swift_name("impersonation")));
@property (class, readonly) NSArray<PrimalSharedReportType *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedReportType *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((swift_name("MessageCipher")))
@protocol PrimalSharedMessageCipher
@required
- (NSString *)decryptMessageUserId:(NSString *)userId participantId:(NSString *)participantId content:(NSString *)content __attribute__((swift_name("decryptMessage(userId:participantId:content:)")));

/**
 * @note This method converts instances of MessageEncryptException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (NSString * _Nullable)encryptMessageUserId:(NSString *)userId participantId:(NSString *)participantId content:(NSString *)content error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("encryptMessage(userId:participantId:content:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MessageEncryptException")))
@interface PrimalSharedMessageEncryptException : PrimalSharedKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((swift_name("NostrEventSignatureHandler")))
@protocol PrimalSharedNostrEventSignatureHandler
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)signNostrEventUnsignedNostrEvent:(PrimalSharedNostrUnsignedEvent *)unsignedNostrEvent completionHandler:(void (^)(PrimalSharedSignResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("signNostrEvent(unsignedNostrEvent:completionHandler:)")));
- (BOOL)verifySignatureNostrEvent:(PrimalSharedNostrEvent *)nostrEvent __attribute__((swift_name("verifySignature(nostrEvent:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrKeyPair")))
@interface PrimalSharedNostrKeyPair : PrimalSharedBase
@property (readonly) NSString *privateKey __attribute__((swift_name("privateKey")));
@property (readonly) NSString *pubKey __attribute__((swift_name("pubKey")));
- (instancetype)initWithPrivateKey:(NSString *)privateKey pubKey:(NSString *)pubKey __attribute__((swift_name("init(privateKey:pubKey:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNostrKeyPair *)doCopyPrivateKey:(NSString *)privateKey pubKey:(NSString *)pubKey __attribute__((swift_name("doCopy(privateKey:pubKey:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("SignResult")))
@interface PrimalSharedSignResult : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SignResult.Rejected")))
@interface PrimalSharedSignResultRejected : PrimalSharedSignResult
@property (readonly) PrimalSharedSignatureException *error __attribute__((swift_name("error")));
- (instancetype)initWithError:(PrimalSharedSignatureException *)error __attribute__((swift_name("init(error:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedSignResultRejected *)doCopyError:(PrimalSharedSignatureException *)error __attribute__((swift_name("doCopy(error:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SignResult.Signed")))
@interface PrimalSharedSignResultSigned : PrimalSharedSignResult
@property (readonly) PrimalSharedNostrEvent *event __attribute__((swift_name("event")));
- (instancetype)initWithEvent:(PrimalSharedNostrEvent *)event __attribute__((swift_name("init(event:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedSignResultSigned *)doCopyEvent:(PrimalSharedNostrEvent *)event __attribute__((swift_name("doCopy(event:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("SignatureException")))
@interface PrimalSharedSignatureException : PrimalSharedKotlinException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SigningKeyNotFoundException")))
@interface PrimalSharedSigningKeyNotFoundException : PrimalSharedSignatureException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("SigningRejectedException")))
@interface PrimalSharedSigningRejectedException : PrimalSharedSignatureException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Bech32")))
@interface PrimalSharedBech32 : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedBech32 *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)bech32 __attribute__((swift_name("init()")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedKotlinTriple<NSString *, PrimalSharedKotlinArray<PrimalSharedByte *> *, PrimalSharedBech32Encoding *> *)decodeBech32:(NSString *)bech32 noChecksum:(BOOL)noChecksum __attribute__((swift_name("decode(bech32:noChecksum:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedKotlinTriple<NSString *, PrimalSharedKotlinByteArray *, PrimalSharedBech32Encoding *> *)decodeBytesBech32:(NSString *)bech32 noChecksum:(BOOL)noChecksum __attribute__((swift_name("decodeBytes(bech32:noChecksum:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedKotlinArray<PrimalSharedByte *> *)eight2fiveInput:(PrimalSharedKotlinByteArray *)input __attribute__((swift_name("eight2five(input:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (NSString *)encodeHrp:(NSString *)hrp int5s:(PrimalSharedKotlinArray<PrimalSharedByte *> *)int5s encoding:(PrimalSharedBech32Encoding *)encoding __attribute__((swift_name("encode(hrp:int5s:encoding:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (NSString *)encodeBytesHrp:(NSString *)hrp data:(PrimalSharedKotlinByteArray *)data encoding:(PrimalSharedBech32Encoding *)encoding __attribute__((swift_name("encodeBytes(hrp:data:encoding:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedKotlinByteArray *)five2eightInput:(PrimalSharedKotlinArray<PrimalSharedByte *> *)input offset:(int32_t)offset __attribute__((swift_name("five2eight(input:offset:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Bech32.Encoding")))
@interface PrimalSharedBech32Encoding : PrimalSharedKotlinEnum<PrimalSharedBech32Encoding *>
@property (class, readonly) PrimalSharedBech32Encoding *bech32 __attribute__((swift_name("bech32")));
@property (class, readonly) PrimalSharedBech32Encoding *bech32m __attribute__((swift_name("bech32m")));
@property (class, readonly) PrimalSharedBech32Encoding *beck32withoutchecksum __attribute__((swift_name("beck32withoutchecksum")));
@property (class, readonly) NSArray<PrimalSharedBech32Encoding *> *entries __attribute__((swift_name("entries")));
@property (readonly) int32_t constant __attribute__((swift_name("constant")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedBech32Encoding *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("CryptoUtils")))
@interface PrimalSharedCryptoUtils : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedCryptoUtils *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)cryptoUtils __attribute__((swift_name("init()")));

/**
 * @note annotations
 *   kotlin.io.encoding.ExperimentalEncodingApi
 * @note This method converts instances of IllegalArgumentException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (NSString * _Nullable)decryptMessage:(NSString *)message privateKey:(PrimalSharedKotlinByteArray *)privateKey pubKey:(PrimalSharedKotlinByteArray *)pubKey error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("decrypt(message:privateKey:pubKey:)")));

/**
 * @note annotations
 *   kotlin.io.encoding.ExperimentalEncodingApi
*/
- (NSString *)encryptMsg:(NSString *)msg privateKey:(PrimalSharedKotlinByteArray *)privateKey pubKey:(PrimalSharedKotlinByteArray *)pubKey __attribute__((swift_name("encrypt(msg:privateKey:pubKey:)")));
- (PrimalSharedNostrKeyPair *)generateHexEncodedKeypair __attribute__((swift_name("generateHexEncodedKeypair()")));
- (PrimalSharedKotlinByteArray *)publicKeyCreatePrivateKey:(PrimalSharedKotlinByteArray *)privateKey __attribute__((swift_name("publicKeyCreate(privateKey:)")));
- (PrimalSharedKotlinByteArray *)sha256ByteArray:(PrimalSharedKotlinByteArray *)byteArray __attribute__((swift_name("sha256(byteArray:)")));
- (PrimalSharedKotlinByteArray *)signData:(PrimalSharedKotlinByteArray *)data privateKey:(PrimalSharedKotlinByteArray *)privateKey __attribute__((swift_name("sign(data:privateKey:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("InvalidNostrPrivateKeyException")))
@interface PrimalSharedInvalidNostrPrivateKeyException : PrimalSharedKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((swift_name("NostrException")))
@interface PrimalSharedNostrException : PrimalSharedKotlinException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("MissingRelaysException")))
@interface PrimalSharedMissingRelaysException : PrimalSharedNostrException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((swift_name("NostrEventPublisher")))
@protocol PrimalSharedNostrEventPublisher
@required

/**
 * @note This method converts instances of NostrPublishException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)publishNostrEventNostrEvent:(PrimalSharedNostrEvent *)nostrEvent outboxRelays:(NSArray<NSString *> *)outboxRelays completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("publishNostrEvent(nostrEvent:outboxRelays:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrPublishException")))
@interface PrimalSharedNostrPublishException : PrimalSharedNostrException
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LnInvoiceUtils")))
@interface PrimalSharedLnInvoiceUtils : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedLnInvoiceUtils *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)lnInvoiceUtils __attribute__((swift_name("init()")));
- (NSString * _Nullable)findInvoiceInput:(NSString * _Nullable)input __attribute__((swift_name("findInvoice(input:)")));
- (PrimalSharedBignumBigDecimal *)getAmountInSatsInvoice:(NSString *)invoice __attribute__((swift_name("getAmountInSats(invoice:)")));
- (PrimalSharedKotlinPair<PrimalSharedInt *, PrimalSharedInt *> *)locateInvoiceInput:(NSString * _Nullable)input __attribute__((swift_name("locateInvoice(input:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LnInvoiceUtils.AddressFormatException")))
@interface PrimalSharedLnInvoiceUtilsAddressFormatException : PrimalSharedKotlinException
- (instancetype)initWithMessage:(NSString *)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((swift_name("NostrZapper")))
@protocol PrimalSharedNostrZapper
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)zapData:(PrimalSharedZapRequestData *)data completionHandler:(void (^)(PrimalSharedZapResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("zap(data:completionHandler:)")));
@end

__attribute__((swift_name("NostrZapperFactory")))
@protocol PrimalSharedNostrZapperFactory
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)createOrNullUserId:(NSString *)userId completionHandler:(void (^)(id<PrimalSharedNostrZapper> _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("createOrNull(userId:completionHandler:)")));
@end

__attribute__((swift_name("ZapError")))
@interface PrimalSharedZapError : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapError.FailedToFetchZapInvoice")))
@interface PrimalSharedZapErrorFailedToFetchZapInvoice : PrimalSharedZapError
@property (readonly) PrimalSharedKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapErrorFailedToFetchZapInvoice *)doCopyCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("doCopy(cause:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapError.FailedToFetchZapPayRequest")))
@interface PrimalSharedZapErrorFailedToFetchZapPayRequest : PrimalSharedZapError
@property (readonly) PrimalSharedKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapErrorFailedToFetchZapPayRequest *)doCopyCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("doCopy(cause:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapError.FailedToPublishEvent")))
@interface PrimalSharedZapErrorFailedToPublishEvent : PrimalSharedZapError
@property (class, readonly, getter=shared) PrimalSharedZapErrorFailedToPublishEvent *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)failedToPublishEvent __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapError.FailedToSignEvent")))
@interface PrimalSharedZapErrorFailedToSignEvent : PrimalSharedZapError
@property (class, readonly, getter=shared) PrimalSharedZapErrorFailedToSignEvent *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)failedToSignEvent __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapError.InvalidZap")))
@interface PrimalSharedZapErrorInvalidZap : PrimalSharedZapError
@property (readonly) NSString *message __attribute__((swift_name("message")));
- (instancetype)initWithMessage:(NSString *)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapErrorInvalidZap *)doCopyMessage:(NSString *)message __attribute__((swift_name("doCopy(message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapError.Unknown")))
@interface PrimalSharedZapErrorUnknown : PrimalSharedZapError
@property (readonly) PrimalSharedKotlinThrowable * _Nullable cause __attribute__((swift_name("cause")));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapErrorUnknown *)doCopyCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("doCopy(cause:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapRequestData")))
@interface PrimalSharedZapRequestData : PrimalSharedBase
@property (readonly) NSString *lnUrlDecoded __attribute__((swift_name("lnUrlDecoded")));
@property (readonly) NSString *targetUserId __attribute__((swift_name("targetUserId")));
@property (readonly) PrimalSharedNostrEvent *userZapRequestEvent __attribute__((swift_name("userZapRequestEvent")));
@property (readonly) uint64_t zapAmountInSats __attribute__((swift_name("zapAmountInSats")));
@property (readonly) NSString *zapComment __attribute__((swift_name("zapComment")));
@property (readonly) NSString *zapperUserId __attribute__((swift_name("zapperUserId")));
- (instancetype)initWithZapperUserId:(NSString *)zapperUserId targetUserId:(NSString *)targetUserId lnUrlDecoded:(NSString *)lnUrlDecoded zapAmountInSats:(uint64_t)zapAmountInSats zapComment:(NSString *)zapComment userZapRequestEvent:(PrimalSharedNostrEvent *)userZapRequestEvent __attribute__((swift_name("init(zapperUserId:targetUserId:lnUrlDecoded:zapAmountInSats:zapComment:userZapRequestEvent:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapRequestData *)doCopyZapperUserId:(NSString *)zapperUserId targetUserId:(NSString *)targetUserId lnUrlDecoded:(NSString *)lnUrlDecoded zapAmountInSats:(uint64_t)zapAmountInSats zapComment:(NSString *)zapComment userZapRequestEvent:(PrimalSharedNostrEvent *)userZapRequestEvent __attribute__((swift_name("doCopy(zapperUserId:targetUserId:lnUrlDecoded:zapAmountInSats:zapComment:userZapRequestEvent:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("ZapResult")))
@interface PrimalSharedZapResult : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapResult.Failure")))
@interface PrimalSharedZapResultFailure : PrimalSharedZapResult
@property (readonly) PrimalSharedZapError *error __attribute__((swift_name("error")));
- (instancetype)initWithError:(PrimalSharedZapError *)error __attribute__((swift_name("init(error:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapResultFailure *)doCopyError:(PrimalSharedZapError *)error __attribute__((swift_name("doCopy(error:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapResult.Success")))
@interface PrimalSharedZapResultSuccess : PrimalSharedZapResult
@property (class, readonly, getter=shared) PrimalSharedZapResultSuccess *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)success __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("ZapTarget")))
@interface PrimalSharedZapTarget : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapTarget.Event")))
@interface PrimalSharedZapTargetEvent : PrimalSharedZapTarget
@property (readonly) NSString *eventAuthorId __attribute__((swift_name("eventAuthorId")));
@property (readonly) NSString *eventAuthorLnUrlDecoded __attribute__((swift_name("eventAuthorLnUrlDecoded")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
- (instancetype)initWithEventId:(NSString *)eventId eventAuthorId:(NSString *)eventAuthorId eventAuthorLnUrlDecoded:(NSString *)eventAuthorLnUrlDecoded __attribute__((swift_name("init(eventId:eventAuthorId:eventAuthorLnUrlDecoded:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapTargetEvent *)doCopyEventId:(NSString *)eventId eventAuthorId:(NSString *)eventAuthorId eventAuthorLnUrlDecoded:(NSString *)eventAuthorLnUrlDecoded __attribute__((swift_name("doCopy(eventId:eventAuthorId:eventAuthorLnUrlDecoded:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapTarget.Profile")))
@interface PrimalSharedZapTargetProfile : PrimalSharedZapTarget
@property (readonly) NSString *profileId __attribute__((swift_name("profileId")));
@property (readonly) NSString *profileLnUrlDecoded __attribute__((swift_name("profileLnUrlDecoded")));
- (instancetype)initWithProfileId:(NSString *)profileId profileLnUrlDecoded:(NSString *)profileLnUrlDecoded __attribute__((swift_name("init(profileId:profileLnUrlDecoded:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapTargetProfile *)doCopyProfileId:(NSString *)profileId profileLnUrlDecoded:(NSString *)profileLnUrlDecoded __attribute__((swift_name("doCopy(profileId:profileLnUrlDecoded:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ZapTarget.ReplaceableEvent")))
@interface PrimalSharedZapTargetReplaceableEvent : PrimalSharedZapTarget
@property (readonly) NSString *eventAuthorId __attribute__((swift_name("eventAuthorId")));
@property (readonly) NSString *eventAuthorLnUrlDecoded __attribute__((swift_name("eventAuthorLnUrlDecoded")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) NSString *identifier __attribute__((swift_name("identifier")));
@property (readonly) int32_t kind __attribute__((swift_name("kind")));
- (instancetype)initWithKind:(int32_t)kind identifier:(NSString *)identifier eventId:(NSString *)eventId eventAuthorId:(NSString *)eventAuthorId eventAuthorLnUrlDecoded:(NSString *)eventAuthorLnUrlDecoded __attribute__((swift_name("init(kind:identifier:eventId:eventAuthorId:eventAuthorLnUrlDecoded:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedZapTargetReplaceableEvent *)doCopyKind:(int32_t)kind identifier:(NSString *)identifier eventId:(NSString *)eventId eventAuthorId:(NSString *)eventAuthorId eventAuthorLnUrlDecoded:(NSString *)eventAuthorLnUrlDecoded __attribute__((swift_name("doCopy(kind:identifier:eventId:eventAuthorId:eventAuthorLnUrlDecoded:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentZapConfigItem")))
@interface PrimalSharedContentZapConfigItem : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedContentZapConfigItemCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t amount __attribute__((swift_name("amount")));
@property (readonly) NSString *emoji __attribute__((swift_name("emoji")));
@property (readonly) NSString *message __attribute__((swift_name("message")));
- (instancetype)initWithEmoji:(NSString *)emoji amount:(int64_t)amount message:(NSString *)message __attribute__((swift_name("init(emoji:amount:message:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedContentZapConfigItem *)doCopyEmoji:(NSString *)emoji amount:(int64_t)amount message:(NSString *)message __attribute__((swift_name("doCopy(emoji:amount:message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentZapConfigItem.Companion")))
@interface PrimalSharedContentZapConfigItemCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedContentZapConfigItemCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentZapDefault")))
@interface PrimalSharedContentZapDefault : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedContentZapDefaultCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t amount __attribute__((swift_name("amount")));
@property (readonly) NSString *message __attribute__((swift_name("message")));
- (instancetype)initWithAmount:(int64_t)amount message:(NSString *)message __attribute__((swift_name("init(amount:message:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedContentZapDefault *)doCopyAmount:(int64_t)amount message:(NSString *)message __attribute__((swift_name("doCopy(amount:message:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentZapDefault.Companion")))
@interface PrimalSharedContentZapDefaultCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedContentZapDefaultCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Notification")))
@interface PrimalSharedNotification : PrimalSharedBase
@property (readonly) PrimalSharedProfileData * _Nullable actionByUser __attribute__((swift_name("actionByUser")));
@property (readonly) PrimalSharedFeedPost * _Nullable actionOnPost __attribute__((swift_name("actionOnPost")));
@property (readonly) NSString * _Nullable actionPostId __attribute__((swift_name("actionPostId")));
@property (readonly) NSString * _Nullable actionUserId __attribute__((swift_name("actionUserId")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString *notificationId __attribute__((swift_name("notificationId")));
@property (readonly) NSString *ownerId __attribute__((swift_name("ownerId")));
@property (readonly) NSString * _Nullable reaction __attribute__((swift_name("reaction")));
@property (readonly) PrimalSharedLong * _Nullable satsZapped __attribute__((swift_name("satsZapped")));
@property (readonly) PrimalSharedLong * _Nullable seenGloballyAt __attribute__((swift_name("seenGloballyAt")));
@property (readonly) PrimalSharedNotificationType *type __attribute__((swift_name("type")));
- (instancetype)initWithNotificationId:(NSString *)notificationId ownerId:(NSString *)ownerId createdAt:(int64_t)createdAt type:(PrimalSharedNotificationType *)type seenGloballyAt:(PrimalSharedLong * _Nullable)seenGloballyAt actionUserId:(NSString * _Nullable)actionUserId actionPostId:(NSString * _Nullable)actionPostId satsZapped:(PrimalSharedLong * _Nullable)satsZapped actionByUser:(PrimalSharedProfileData * _Nullable)actionByUser actionOnPost:(PrimalSharedFeedPost * _Nullable)actionOnPost reaction:(NSString * _Nullable)reaction __attribute__((swift_name("init(notificationId:ownerId:createdAt:type:seenGloballyAt:actionUserId:actionPostId:satsZapped:actionByUser:actionOnPost:reaction:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedNotification *)doCopyNotificationId:(NSString *)notificationId ownerId:(NSString *)ownerId createdAt:(int64_t)createdAt type:(PrimalSharedNotificationType *)type seenGloballyAt:(PrimalSharedLong * _Nullable)seenGloballyAt actionUserId:(NSString * _Nullable)actionUserId actionPostId:(NSString * _Nullable)actionPostId satsZapped:(PrimalSharedLong * _Nullable)satsZapped actionByUser:(PrimalSharedProfileData * _Nullable)actionByUser actionOnPost:(PrimalSharedFeedPost * _Nullable)actionOnPost reaction:(NSString * _Nullable)reaction __attribute__((swift_name("doCopy(notificationId:ownerId:createdAt:type:seenGloballyAt:actionUserId:actionPostId:satsZapped:actionByUser:actionOnPost:reaction:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("NotificationRepository")))
@protocol PrimalSharedNotificationRepository
@required

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)markAllNotificationsAsSeenAuthorization:(PrimalSharedNostrEvent *)authorization completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("markAllNotificationsAsSeen(authorization:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeSeenNotificationsUserId:(NSString *)userId __attribute__((swift_name("observeSeenNotifications(userId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeUnseenNotificationsOwnerId:(NSString *)ownerId __attribute__((swift_name("observeUnseenNotifications(ownerId:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsSection")))
@interface PrimalSharedNotificationSettingsSection : PrimalSharedKotlinEnum<PrimalSharedNotificationSettingsSection *>
@property (class, readonly) PrimalSharedNotificationSettingsSection *pushNotifications __attribute__((swift_name("pushNotifications")));
@property (class, readonly) PrimalSharedNotificationSettingsSection *notificationsInTab __attribute__((swift_name("notificationsInTab")));
@property (class, readonly) PrimalSharedNotificationSettingsSection *preferences __attribute__((swift_name("preferences")));
@property (class, readonly) NSArray<PrimalSharedNotificationSettingsSection *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedNotificationSettingsSection *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((swift_name("NotificationSettingsType")))
@interface PrimalSharedNotificationSettingsType : PrimalSharedBase
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) int32_t order __attribute__((swift_name("order")));
@end

__attribute__((swift_name("NotificationSettingsType.Preferences")))
@interface PrimalSharedNotificationSettingsTypePreferences : PrimalSharedNotificationSettingsType
@property (class, readonly, getter=companion) PrimalSharedNotificationSettingsTypePreferencesCompanion *companion __attribute__((swift_name("companion")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PreferencesCompanion")))
@interface PrimalSharedNotificationSettingsTypePreferencesCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePreferencesCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedNotificationSettingsTypePreferences * _Nullable)valueOfId:(NSString *)id __attribute__((swift_name("valueOf(id:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PreferencesDMsFromFollows")))
@interface PrimalSharedNotificationSettingsTypePreferencesDMsFromFollows : PrimalSharedNotificationSettingsTypePreferences
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePreferencesDMsFromFollows *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)dMsFromFollows __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PreferencesHellThread")))
@interface PrimalSharedNotificationSettingsTypePreferencesHellThread : PrimalSharedNotificationSettingsTypePreferences
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePreferencesHellThread *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)hellThread __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PreferencesReactionsFromFollows")))
@interface PrimalSharedNotificationSettingsTypePreferencesReactionsFromFollows : PrimalSharedNotificationSettingsTypePreferences
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePreferencesReactionsFromFollows *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)reactionsFromFollows __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("NotificationSettingsType.PushNotifications")))
@interface PrimalSharedNotificationSettingsTypePushNotifications : PrimalSharedNotificationSettingsType
@property (class, readonly, getter=companion) PrimalSharedNotificationSettingsTypePushNotificationsCompanion *companion __attribute__((swift_name("companion")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsCompanion")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedNotificationSettingsTypePushNotifications * _Nullable)valueOfId:(NSString *)id __attribute__((swift_name("valueOf(id:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsDirectMessages")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsDirectMessages : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsDirectMessages *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)directMessages __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsMentions")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsMentions : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsMentions *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)mentions __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsNewFollows")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsNewFollows : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsNewFollows *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)getNewFollows __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsReactions")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsReactions : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsReactions *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)reactions __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsReplies")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsReplies : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsReplies *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)replies __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsReposts")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsReposts : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsReposts *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)reposts __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsWalletTransactions")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsWalletTransactions : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsWalletTransactions *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)walletTransactions __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.PushNotificationsZaps")))
@interface PrimalSharedNotificationSettingsTypePushNotificationsZaps : PrimalSharedNotificationSettingsTypePushNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypePushNotificationsZaps *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)zaps __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("NotificationSettingsType.TabNotifications")))
@interface PrimalSharedNotificationSettingsTypeTabNotifications : PrimalSharedNotificationSettingsType
@property (readonly) NSArray<PrimalSharedNotificationType *> *types __attribute__((swift_name("types")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.TabNotificationsMentions")))
@interface PrimalSharedNotificationSettingsTypeTabNotificationsMentions : PrimalSharedNotificationSettingsTypeTabNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypeTabNotificationsMentions *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)mentions __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.TabNotificationsNewFollows")))
@interface PrimalSharedNotificationSettingsTypeTabNotificationsNewFollows : PrimalSharedNotificationSettingsTypeTabNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypeTabNotificationsNewFollows *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)getNewFollows __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.TabNotificationsReactions")))
@interface PrimalSharedNotificationSettingsTypeTabNotificationsReactions : PrimalSharedNotificationSettingsTypeTabNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypeTabNotificationsReactions *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)reactions __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.TabNotificationsReplies")))
@interface PrimalSharedNotificationSettingsTypeTabNotificationsReplies : PrimalSharedNotificationSettingsTypeTabNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypeTabNotificationsReplies *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)replies __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.TabNotificationsReposts")))
@interface PrimalSharedNotificationSettingsTypeTabNotificationsReposts : PrimalSharedNotificationSettingsTypeTabNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypeTabNotificationsReposts *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)reposts __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationSettingsType.TabNotificationsZaps")))
@interface PrimalSharedNotificationSettingsTypeTabNotificationsZaps : PrimalSharedNotificationSettingsTypeTabNotifications
@property (class, readonly, getter=shared) PrimalSharedNotificationSettingsTypeTabNotificationsZaps *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)zaps __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationType")))
@interface PrimalSharedNotificationType : PrimalSharedKotlinEnum<PrimalSharedNotificationType *>
@property (class, readonly, getter=companion) PrimalSharedNotificationTypeCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) PrimalSharedNotificationType *theNewUserFollowedYou __attribute__((swift_name("theNewUserFollowedYou")));
@property (class, readonly) PrimalSharedNotificationType *yourPostWasZapped __attribute__((swift_name("yourPostWasZapped")));
@property (class, readonly) PrimalSharedNotificationType *yourPostWasLiked __attribute__((swift_name("yourPostWasLiked")));
@property (class, readonly) PrimalSharedNotificationType *yourPostWasReposted __attribute__((swift_name("yourPostWasReposted")));
@property (class, readonly) PrimalSharedNotificationType *yourPostWasRepliedTo __attribute__((swift_name("yourPostWasRepliedTo")));
@property (class, readonly) PrimalSharedNotificationType *youWereMentionedInPost __attribute__((swift_name("youWereMentionedInPost")));
@property (class, readonly) PrimalSharedNotificationType *yourPostWasMentionedInPost __attribute__((swift_name("yourPostWasMentionedInPost")));
@property (class, readonly) PrimalSharedNotificationType *postYouWereMentionedInWasZapped __attribute__((swift_name("postYouWereMentionedInWasZapped")));
@property (class, readonly) PrimalSharedNotificationType *postYouWereMentionedInWasLiked __attribute__((swift_name("postYouWereMentionedInWasLiked")));
@property (class, readonly) PrimalSharedNotificationType *postYouWereMentionedInWasReposted __attribute__((swift_name("postYouWereMentionedInWasReposted")));
@property (class, readonly) PrimalSharedNotificationType *postYouWereMentionedInWasRepliedTo __attribute__((swift_name("postYouWereMentionedInWasRepliedTo")));
@property (class, readonly) PrimalSharedNotificationType *postYourPostWasMentionedInWasZapped __attribute__((swift_name("postYourPostWasMentionedInWasZapped")));
@property (class, readonly) PrimalSharedNotificationType *postYourPostWasMentionedInWasLiked __attribute__((swift_name("postYourPostWasMentionedInWasLiked")));
@property (class, readonly) PrimalSharedNotificationType *postYourPostWasMentionedInWasReposted __attribute__((swift_name("postYourPostWasMentionedInWasReposted")));
@property (class, readonly) PrimalSharedNotificationType *postYourPostWasMentionedInWasRepliedTo __attribute__((swift_name("postYourPostWasMentionedInWasRepliedTo")));
@property (class, readonly) PrimalSharedNotificationType *yourPostWasHighlighted __attribute__((swift_name("yourPostWasHighlighted")));
@property (class, readonly) PrimalSharedNotificationType *yourPostWasBookmarked __attribute__((swift_name("yourPostWasBookmarked")));
@property (class, readonly) NSArray<PrimalSharedNotificationType *> *entries __attribute__((swift_name("entries")));
@property (readonly) BOOL collapsable __attribute__((swift_name("collapsable")));
@property (readonly) NSString *id __attribute__((swift_name("id")));
@property (readonly) int32_t type __attribute__((swift_name("type")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedNotificationType *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NotificationType.Companion")))
@interface PrimalSharedNotificationTypeCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedNotificationTypeCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedNotificationType * _Nullable)valueOfType:(int32_t)type __attribute__((swift_name("valueOf(type:)")));
- (PrimalSharedNotificationType * _Nullable)valueOfId:(NSString *)id __attribute__((swift_name("valueOf(id:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedPageSnapshot")))
@interface PrimalSharedFeedPageSnapshot : PrimalSharedBase
@property (readonly) NSArray<PrimalSharedNostrEvent *> *articles __attribute__((swift_name("articles")));
@property (readonly) NSArray<PrimalSharedNostrEvent *> *blossomServers __attribute__((swift_name("blossomServers")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *cdnResources __attribute__((swift_name("cdnResources")));
@property (readonly) NSArray<PrimalSharedNostrEvent *> *genericReposts __attribute__((swift_name("genericReposts")));
@property (readonly) NSArray<PrimalSharedNostrEvent *> *metadata __attribute__((swift_name("metadata")));
@property (readonly) NSArray<PrimalSharedNostrEvent *> *notes __attribute__((swift_name("notes")));
@property (readonly) PrimalSharedContentPrimalPaging * _Nullable paging __attribute__((swift_name("paging")));
@property (readonly) NSArray<PrimalSharedNostrEvent *> *pictureNotes __attribute__((swift_name("pictureNotes")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *primalEventStats __attribute__((swift_name("primalEventStats")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *primalEventUserStats __attribute__((swift_name("primalEventUserStats")));
@property (readonly) PrimalSharedPrimalEvent * _Nullable primalLegendProfiles __attribute__((swift_name("primalLegendProfiles")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *primalLinkPreviews __attribute__((swift_name("primalLinkPreviews")));
@property (readonly) PrimalSharedPrimalEvent * _Nullable primalPremiumInfo __attribute__((swift_name("primalPremiumInfo")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *primalRelayHints __attribute__((swift_name("primalRelayHints")));
@property (readonly) PrimalSharedPrimalEvent * _Nullable primalUserNames __attribute__((swift_name("primalUserNames")));
@property (readonly) NSArray<PrimalSharedPrimalEvent *> *referencedEvents __attribute__((swift_name("referencedEvents")));
@property (readonly) NSArray<PrimalSharedNostrEvent *> *reposts __attribute__((swift_name("reposts")));
@property (readonly) NSArray<PrimalSharedNostrEvent *> *zaps __attribute__((swift_name("zaps")));
- (instancetype)initWithPaging:(PrimalSharedContentPrimalPaging * _Nullable)paging metadata:(NSArray<PrimalSharedNostrEvent *> *)metadata notes:(NSArray<PrimalSharedNostrEvent *> *)notes articles:(NSArray<PrimalSharedNostrEvent *> *)articles reposts:(NSArray<PrimalSharedNostrEvent *> *)reposts zaps:(NSArray<PrimalSharedNostrEvent *> *)zaps referencedEvents:(NSArray<PrimalSharedPrimalEvent *> *)referencedEvents primalEventStats:(NSArray<PrimalSharedPrimalEvent *> *)primalEventStats primalEventUserStats:(NSArray<PrimalSharedPrimalEvent *> *)primalEventUserStats cdnResources:(NSArray<PrimalSharedPrimalEvent *> *)cdnResources primalLinkPreviews:(NSArray<PrimalSharedPrimalEvent *> *)primalLinkPreviews primalRelayHints:(NSArray<PrimalSharedPrimalEvent *> *)primalRelayHints blossomServers:(NSArray<PrimalSharedNostrEvent *> *)blossomServers primalUserNames:(PrimalSharedPrimalEvent * _Nullable)primalUserNames primalLegendProfiles:(PrimalSharedPrimalEvent * _Nullable)primalLegendProfiles primalPremiumInfo:(PrimalSharedPrimalEvent * _Nullable)primalPremiumInfo genericReposts:(NSArray<PrimalSharedNostrEvent *> *)genericReposts pictureNotes:(NSArray<PrimalSharedNostrEvent *> *)pictureNotes __attribute__((swift_name("init(paging:metadata:notes:articles:reposts:zaps:referencedEvents:primalEventStats:primalEventUserStats:cdnResources:primalLinkPreviews:primalRelayHints:blossomServers:primalUserNames:primalLegendProfiles:primalPremiumInfo:genericReposts:pictureNotes:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFeedPageSnapshot *)doCopyPaging:(PrimalSharedContentPrimalPaging * _Nullable)paging metadata:(NSArray<PrimalSharedNostrEvent *> *)metadata notes:(NSArray<PrimalSharedNostrEvent *> *)notes articles:(NSArray<PrimalSharedNostrEvent *> *)articles reposts:(NSArray<PrimalSharedNostrEvent *> *)reposts zaps:(NSArray<PrimalSharedNostrEvent *> *)zaps referencedEvents:(NSArray<PrimalSharedPrimalEvent *> *)referencedEvents primalEventStats:(NSArray<PrimalSharedPrimalEvent *> *)primalEventStats primalEventUserStats:(NSArray<PrimalSharedPrimalEvent *> *)primalEventUserStats cdnResources:(NSArray<PrimalSharedPrimalEvent *> *)cdnResources primalLinkPreviews:(NSArray<PrimalSharedPrimalEvent *> *)primalLinkPreviews primalRelayHints:(NSArray<PrimalSharedPrimalEvent *> *)primalRelayHints blossomServers:(NSArray<PrimalSharedNostrEvent *> *)blossomServers primalUserNames:(PrimalSharedPrimalEvent * _Nullable)primalUserNames primalLegendProfiles:(PrimalSharedPrimalEvent * _Nullable)primalLegendProfiles primalPremiumInfo:(PrimalSharedPrimalEvent * _Nullable)primalPremiumInfo genericReposts:(NSArray<PrimalSharedNostrEvent *> *)genericReposts pictureNotes:(NSArray<PrimalSharedNostrEvent *> *)pictureNotes __attribute__((swift_name("doCopy(paging:metadata:notes:articles:reposts:zaps:referencedEvents:primalEventStats:primalEventUserStats:cdnResources:primalLinkPreviews:primalRelayHints:blossomServers:primalUserNames:primalLegendProfiles:primalPremiumInfo:genericReposts:pictureNotes:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedPost")))
@interface PrimalSharedFeedPost : PrimalSharedBase
@property (readonly) PrimalSharedFeedPostAuthor *author __attribute__((swift_name("author")));
@property (readonly) PrimalSharedPublicBookmark * _Nullable bookmark __attribute__((swift_name("bookmark")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) PrimalSharedEventRelayHints * _Nullable eventRelayHints __attribute__((swift_name("eventRelayHints")));
@property (readonly) NSArray<PrimalSharedEventZap *> *eventZaps __attribute__((swift_name("eventZaps")));
@property (readonly) NSArray<NSString *> *hashtags __attribute__((swift_name("hashtags")));
@property (readonly) BOOL isThreadMuted __attribute__((swift_name("isThreadMuted")));
@property (readonly) NSArray<PrimalSharedEventLink *> *links __attribute__((swift_name("links")));
@property (readonly) NSArray<PrimalSharedEventUriNostrReference *> *nostrUris __attribute__((swift_name("nostrUris")));
@property (readonly) NSString *rawNostrEvent __attribute__((swift_name("rawNostrEvent")));
@property (readonly) PrimalSharedFeedPostAuthor * _Nullable replyToAuthor __attribute__((swift_name("replyToAuthor")));
@property (readonly) NSArray<PrimalSharedFeedPostRepostInfo *> *reposts __attribute__((swift_name("reposts")));
@property (readonly) PrimalSharedFeedPostStats * _Nullable stats __attribute__((swift_name("stats")));
@property (readonly) NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *tags __attribute__((swift_name("tags")));
@property (readonly) PrimalSharedKotlinx_datetimeInstant *timestamp __attribute__((swift_name("timestamp")));
- (instancetype)initWithEventId:(NSString *)eventId author:(PrimalSharedFeedPostAuthor *)author content:(NSString *)content tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags timestamp:(PrimalSharedKotlinx_datetimeInstant *)timestamp rawNostrEvent:(NSString *)rawNostrEvent hashtags:(NSArray<NSString *> *)hashtags replyToAuthor:(PrimalSharedFeedPostAuthor * _Nullable)replyToAuthor reposts:(NSArray<PrimalSharedFeedPostRepostInfo *> *)reposts stats:(PrimalSharedFeedPostStats * _Nullable)stats links:(NSArray<PrimalSharedEventLink *> *)links nostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)nostrUris eventZaps:(NSArray<PrimalSharedEventZap *> *)eventZaps bookmark:(PrimalSharedPublicBookmark * _Nullable)bookmark isThreadMuted:(BOOL)isThreadMuted eventRelayHints:(PrimalSharedEventRelayHints * _Nullable)eventRelayHints __attribute__((swift_name("init(eventId:author:content:tags:timestamp:rawNostrEvent:hashtags:replyToAuthor:reposts:stats:links:nostrUris:eventZaps:bookmark:isThreadMuted:eventRelayHints:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFeedPost *)doCopyEventId:(NSString *)eventId author:(PrimalSharedFeedPostAuthor *)author content:(NSString *)content tags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)tags timestamp:(PrimalSharedKotlinx_datetimeInstant *)timestamp rawNostrEvent:(NSString *)rawNostrEvent hashtags:(NSArray<NSString *> *)hashtags replyToAuthor:(PrimalSharedFeedPostAuthor * _Nullable)replyToAuthor reposts:(NSArray<PrimalSharedFeedPostRepostInfo *> *)reposts stats:(PrimalSharedFeedPostStats * _Nullable)stats links:(NSArray<PrimalSharedEventLink *> *)links nostrUris:(NSArray<PrimalSharedEventUriNostrReference *> *)nostrUris eventZaps:(NSArray<PrimalSharedEventZap *> *)eventZaps bookmark:(PrimalSharedPublicBookmark * _Nullable)bookmark isThreadMuted:(BOOL)isThreadMuted eventRelayHints:(PrimalSharedEventRelayHints * _Nullable)eventRelayHints __attribute__((swift_name("doCopy(eventId:author:content:tags:timestamp:rawNostrEvent:hashtags:replyToAuthor:reposts:stats:links:nostrUris:eventZaps:bookmark:isThreadMuted:eventRelayHints:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedPostAuthor")))
@interface PrimalSharedFeedPostAuthor : PrimalSharedBase
@property (readonly) NSString *authorId __attribute__((swift_name("authorId")));
@property (readonly) PrimalSharedCdnImage * _Nullable avatarCdnImage __attribute__((swift_name("avatarCdnImage")));
@property (readonly) NSArray<NSString *> *blossomServers __attribute__((swift_name("blossomServers")));
@property (readonly) NSString *displayName __attribute__((swift_name("displayName")));
@property (readonly) NSString *handle __attribute__((swift_name("handle")));
@property (readonly) NSString * _Nullable internetIdentifier __attribute__((swift_name("internetIdentifier")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable legendProfile __attribute__((swift_name("legendProfile")));
@property (readonly) NSString * _Nullable rawNostrEvent __attribute__((swift_name("rawNostrEvent")));
- (instancetype)initWithAuthorId:(NSString *)authorId handle:(NSString *)handle displayName:(NSString *)displayName rawNostrEvent:(NSString * _Nullable)rawNostrEvent internetIdentifier:(NSString * _Nullable)internetIdentifier avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage legendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)legendProfile blossomServers:(NSArray<NSString *> *)blossomServers __attribute__((swift_name("init(authorId:handle:displayName:rawNostrEvent:internetIdentifier:avatarCdnImage:legendProfile:blossomServers:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFeedPostAuthor *)doCopyAuthorId:(NSString *)authorId handle:(NSString *)handle displayName:(NSString *)displayName rawNostrEvent:(NSString * _Nullable)rawNostrEvent internetIdentifier:(NSString * _Nullable)internetIdentifier avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage legendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)legendProfile blossomServers:(NSArray<NSString *> *)blossomServers __attribute__((swift_name("doCopy(authorId:handle:displayName:rawNostrEvent:internetIdentifier:avatarCdnImage:legendProfile:blossomServers:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedPostRepostInfo")))
@interface PrimalSharedFeedPostRepostInfo : PrimalSharedBase
@property (readonly) NSString * _Nullable repostAuthorDisplayName __attribute__((swift_name("repostAuthorDisplayName")));
@property (readonly) NSString * _Nullable repostAuthorId __attribute__((swift_name("repostAuthorId")));
@property (readonly) PrimalSharedLong * _Nullable repostCreatedAt __attribute__((swift_name("repostCreatedAt")));
@property (readonly) NSString *repostId __attribute__((swift_name("repostId")));
- (instancetype)initWithRepostId:(NSString *)repostId repostAuthorId:(NSString * _Nullable)repostAuthorId repostAuthorDisplayName:(NSString * _Nullable)repostAuthorDisplayName repostCreatedAt:(PrimalSharedLong * _Nullable)repostCreatedAt __attribute__((swift_name("init(repostId:repostAuthorId:repostAuthorDisplayName:repostCreatedAt:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFeedPostRepostInfo *)doCopyRepostId:(NSString *)repostId repostAuthorId:(NSString * _Nullable)repostAuthorId repostAuthorDisplayName:(NSString * _Nullable)repostAuthorDisplayName repostCreatedAt:(PrimalSharedLong * _Nullable)repostCreatedAt __attribute__((swift_name("doCopy(repostId:repostAuthorId:repostAuthorDisplayName:repostCreatedAt:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedPostStats")))
@interface PrimalSharedFeedPostStats : PrimalSharedBase
@property (readonly) int64_t likesCount __attribute__((swift_name("likesCount")));
@property (readonly) int64_t repliesCount __attribute__((swift_name("repliesCount")));
@property (readonly) int64_t repostsCount __attribute__((swift_name("repostsCount")));
@property (readonly) int64_t satsZapped __attribute__((swift_name("satsZapped")));
@property (readonly) BOOL userBookmarked __attribute__((swift_name("userBookmarked")));
@property (readonly) BOOL userLiked __attribute__((swift_name("userLiked")));
@property (readonly) BOOL userReplied __attribute__((swift_name("userReplied")));
@property (readonly) BOOL userReposted __attribute__((swift_name("userReposted")));
@property (readonly) BOOL userZapped __attribute__((swift_name("userZapped")));
@property (readonly) int64_t zapsCount __attribute__((swift_name("zapsCount")));
- (instancetype)initWithRepliesCount:(int64_t)repliesCount userReplied:(BOOL)userReplied zapsCount:(int64_t)zapsCount satsZapped:(int64_t)satsZapped userZapped:(BOOL)userZapped likesCount:(int64_t)likesCount userLiked:(BOOL)userLiked repostsCount:(int64_t)repostsCount userReposted:(BOOL)userReposted userBookmarked:(BOOL)userBookmarked __attribute__((swift_name("init(repliesCount:userReplied:zapsCount:satsZapped:userZapped:likesCount:userLiked:repostsCount:userReposted:userBookmarked:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedFeedPostStats *)doCopyRepliesCount:(int64_t)repliesCount userReplied:(BOOL)userReplied zapsCount:(int64_t)zapsCount satsZapped:(int64_t)satsZapped userZapped:(BOOL)userZapped likesCount:(int64_t)likesCount userLiked:(BOOL)userLiked repostsCount:(int64_t)repostsCount userReposted:(BOOL)userReposted userBookmarked:(BOOL)userBookmarked __attribute__((swift_name("doCopy(repliesCount:userReplied:zapsCount:satsZapped:userZapped:likesCount:userLiked:repostsCount:userReposted:userBookmarked:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("FeedRepository")))
@protocol PrimalSharedFeedRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)deletePostByIdPostId:(NSString *)postId userId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("deletePostById(postId:userId:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)feedBySpecUserId:(NSString *)userId feedSpec:(NSString *)feedSpec allowMutedThreads:(BOOL)allowMutedThreads __attribute__((swift_name("feedBySpec(userId:feedSpec:allowMutedThreads:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchConversationUserId:(NSString *)userId noteId:(NSString *)noteId limit:(int32_t)limit completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchConversation(userId:noteId:limit:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchFeedPageSnapshotUserId:(NSString *)userId feedSpec:(NSString *)feedSpec notes:(NSString * _Nullable)notes until:(PrimalSharedLong * _Nullable)until since:(PrimalSharedLong * _Nullable)since order:(NSString * _Nullable)order limit:(int32_t)limit completionHandler:(void (^)(PrimalSharedFeedPageSnapshot * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchFeedPageSnapshot(userId:feedSpec:notes:until:since:order:limit:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchRepliesUserId:(NSString *)userId noteId:(NSString *)noteId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchReplies(userId:noteId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findAllPostsByIdsPostIds:(NSArray<NSString *> *)postIds completionHandler:(void (^)(NSArray<PrimalSharedFeedPost *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("findAllPostsByIds(postIds:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findConversationUserId:(NSString *)userId noteId:(NSString *)noteId completionHandler:(void (^)(NSArray<PrimalSharedFeedPost *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("findConversation(userId:noteId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findNewestPostsUserId:(NSString *)userId feedDirective:(NSString *)feedDirective allowMutedThreads:(BOOL)allowMutedThreads limit:(int32_t)limit completionHandler:(void (^)(NSArray<PrimalSharedFeedPost *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("findNewestPosts(userId:feedDirective:allowMutedThreads:limit:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findPostsByIdPostId:(NSString *)postId completionHandler:(void (^)(PrimalSharedFeedPost * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("findPostsById(postId:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeConversationUserId:(NSString *)userId noteId:(NSString *)noteId __attribute__((swift_name("observeConversation(userId:noteId:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)removeFeedSpecUserId:(NSString *)userId feedSpec:(NSString *)feedSpec completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("removeFeedSpec(userId:feedSpec:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)replaceFeedUserId:(NSString *)userId feedSpec:(NSString *)feedSpec snapshot:(PrimalSharedFeedPageSnapshot *)snapshot completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("replaceFeed(userId:feedSpec:snapshot:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedRepositoryCompanion")))
@interface PrimalSharedFeedRepositoryCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedFeedRepositoryCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) int32_t DEFAULT_PAGE_SIZE __attribute__((swift_name("DEFAULT_PAGE_SIZE")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentProfilePremiumInfo")))
@interface PrimalSharedContentProfilePremiumInfo : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedContentProfilePremiumInfoCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString * _Nullable cohort1 __attribute__((swift_name("cohort1")));
@property (readonly) NSString * _Nullable cohort2 __attribute__((swift_name("cohort2")));
@property (readonly) PrimalSharedLong * _Nullable expiresAt __attribute__((swift_name("expiresAt")));
@property (readonly) PrimalSharedLong * _Nullable legendSince __attribute__((swift_name("legendSince")));
@property (readonly) PrimalSharedLong * _Nullable premiumSince __attribute__((swift_name("premiumSince")));
@property (readonly) NSString * _Nullable tier __attribute__((swift_name("tier")));
- (instancetype)initWithCohort1:(NSString * _Nullable)cohort1 cohort2:(NSString * _Nullable)cohort2 tier:(NSString * _Nullable)tier expiresAt:(PrimalSharedLong * _Nullable)expiresAt legendSince:(PrimalSharedLong * _Nullable)legendSince premiumSince:(PrimalSharedLong * _Nullable)premiumSince __attribute__((swift_name("init(cohort1:cohort2:tier:expiresAt:legendSince:premiumSince:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedContentProfilePremiumInfo *)doCopyCohort1:(NSString * _Nullable)cohort1 cohort2:(NSString * _Nullable)cohort2 tier:(NSString * _Nullable)tier expiresAt:(PrimalSharedLong * _Nullable)expiresAt legendSince:(PrimalSharedLong * _Nullable)legendSince premiumSince:(PrimalSharedLong * _Nullable)premiumSince __attribute__((swift_name("doCopy(cohort1:cohort2:tier:expiresAt:legendSince:premiumSince:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="cohort_1")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="cohort_2")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="expires_on")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="legend_since")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="premium_since")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="tier")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentProfilePremiumInfo.Companion")))
@interface PrimalSharedContentProfilePremiumInfoCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedContentProfilePremiumInfoCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LeaderboardLegendEntry")))
@interface PrimalSharedLeaderboardLegendEntry : PrimalSharedBase
@property (readonly) PrimalSharedCdnImage * _Nullable avatarCdnImage __attribute__((swift_name("avatarCdnImage")));
@property (readonly) NSString * _Nullable displayName __attribute__((swift_name("displayName")));
@property (readonly) uint64_t donatedSats __attribute__((swift_name("donatedSats")));
@property (readonly) NSString * _Nullable internetIdentifier __attribute__((swift_name("internetIdentifier")));
@property (readonly) PrimalSharedLong * _Nullable legendSince __attribute__((swift_name("legendSince")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable primalLegendProfile __attribute__((swift_name("primalLegendProfile")));
@property (readonly) NSString *userId __attribute__((swift_name("userId")));
- (instancetype)initWithUserId:(NSString *)userId avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage displayName:(NSString * _Nullable)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier legendSince:(PrimalSharedLong * _Nullable)legendSince primalLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)primalLegendProfile donatedSats:(uint64_t)donatedSats __attribute__((swift_name("init(userId:avatarCdnImage:displayName:internetIdentifier:legendSince:primalLegendProfile:donatedSats:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedLeaderboardLegendEntry *)doCopyUserId:(NSString *)userId avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage displayName:(NSString * _Nullable)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier legendSince:(PrimalSharedLong * _Nullable)legendSince primalLegendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)primalLegendProfile donatedSats:(uint64_t)donatedSats __attribute__((swift_name("doCopy(userId:avatarCdnImage:displayName:internetIdentifier:legendSince:primalLegendProfile:donatedSats:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("OGLeaderboardEntry")))
@interface PrimalSharedOGLeaderboardEntry : PrimalSharedBase
@property (readonly) PrimalSharedCdnImage * _Nullable avatarCdnImage __attribute__((swift_name("avatarCdnImage")));
@property (readonly) NSString * _Nullable displayName __attribute__((swift_name("displayName")));
@property (readonly) NSString * _Nullable firstCohort __attribute__((swift_name("firstCohort")));
@property (readonly) int32_t index __attribute__((swift_name("index")));
@property (readonly) NSString * _Nullable internetIdentifier __attribute__((swift_name("internetIdentifier")));
@property (readonly) PrimalSharedLong * _Nullable premiumSince __attribute__((swift_name("premiumSince")));
@property (readonly) NSString * _Nullable secondCohort __attribute__((swift_name("secondCohort")));
@property (readonly) NSString *userId __attribute__((swift_name("userId")));
- (instancetype)initWithIndex:(int32_t)index userId:(NSString *)userId avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage displayName:(NSString * _Nullable)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier firstCohort:(NSString * _Nullable)firstCohort secondCohort:(NSString * _Nullable)secondCohort premiumSince:(PrimalSharedLong * _Nullable)premiumSince __attribute__((swift_name("init(index:userId:avatarCdnImage:displayName:internetIdentifier:firstCohort:secondCohort:premiumSince:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedOGLeaderboardEntry *)doCopyIndex:(int32_t)index userId:(NSString *)userId avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage displayName:(NSString * _Nullable)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier firstCohort:(NSString * _Nullable)firstCohort secondCohort:(NSString * _Nullable)secondCohort premiumSince:(PrimalSharedLong * _Nullable)premiumSince __attribute__((swift_name("doCopy(index:userId:avatarCdnImage:displayName:internetIdentifier:firstCohort:secondCohort:premiumSince:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalLegendProfile")))
@interface PrimalSharedPrimalLegendProfile : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPrimalLegendProfileCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) BOOL avatarGlow __attribute__((swift_name("avatarGlow")));
@property (readonly) NSString * _Nullable currentShoutout __attribute__((swift_name("currentShoutout")));
@property (readonly) BOOL customBadge __attribute__((swift_name("customBadge")));
@property (readonly) PrimalSharedBoolean * _Nullable inLeaderboard __attribute__((swift_name("inLeaderboard")));
@property (readonly) NSString * _Nullable styleId __attribute__((swift_name("styleId")));
- (instancetype)initWithStyleId:(NSString * _Nullable)styleId customBadge:(BOOL)customBadge avatarGlow:(BOOL)avatarGlow inLeaderboard:(PrimalSharedBoolean * _Nullable)inLeaderboard currentShoutout:(NSString * _Nullable)currentShoutout __attribute__((swift_name("init(styleId:customBadge:avatarGlow:inLeaderboard:currentShoutout:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalLegendProfile *)doCopyStyleId:(NSString * _Nullable)styleId customBadge:(BOOL)customBadge avatarGlow:(BOOL)avatarGlow inLeaderboard:(PrimalSharedBoolean * _Nullable)inLeaderboard currentShoutout:(NSString * _Nullable)currentShoutout __attribute__((swift_name("doCopy(styleId:customBadge:avatarGlow:inLeaderboard:currentShoutout:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="avatar_glow")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="current_shoutout")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="custom_badge")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="in_leaderboard")
*/

/**
 * @note annotations
 *   kotlinx.serialization.SerialName(value="style")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalLegendProfile.Companion")))
@interface PrimalSharedPrimalLegendProfileCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPrimalLegendProfileCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalPremiumInfo")))
@interface PrimalSharedPrimalPremiumInfo : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPrimalPremiumInfoCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString * _Nullable cohort1 __attribute__((swift_name("cohort1")));
@property (readonly) NSString * _Nullable cohort2 __attribute__((swift_name("cohort2")));
@property (readonly) PrimalSharedLong * _Nullable expiresAt __attribute__((swift_name("expiresAt")));
@property (readonly) PrimalSharedPrimalLegendProfile * _Nullable legendProfile __attribute__((swift_name("legendProfile")));
@property (readonly) PrimalSharedLong * _Nullable legendSince __attribute__((swift_name("legendSince")));
@property (readonly) PrimalSharedLong * _Nullable premiumSince __attribute__((swift_name("premiumSince")));
@property (readonly) NSString * _Nullable primalName __attribute__((swift_name("primalName")));
@property (readonly) NSString * _Nullable tier __attribute__((swift_name("tier")));
- (instancetype)initWithPrimalName:(NSString * _Nullable)primalName cohort1:(NSString * _Nullable)cohort1 cohort2:(NSString * _Nullable)cohort2 tier:(NSString * _Nullable)tier expiresAt:(PrimalSharedLong * _Nullable)expiresAt legendSince:(PrimalSharedLong * _Nullable)legendSince premiumSince:(PrimalSharedLong * _Nullable)premiumSince legendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)legendProfile __attribute__((swift_name("init(primalName:cohort1:cohort2:tier:expiresAt:legendSince:premiumSince:legendProfile:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalPremiumInfo *)doCopyPrimalName:(NSString * _Nullable)primalName cohort1:(NSString * _Nullable)cohort1 cohort2:(NSString * _Nullable)cohort2 tier:(NSString * _Nullable)tier expiresAt:(PrimalSharedLong * _Nullable)expiresAt legendSince:(PrimalSharedLong * _Nullable)legendSince premiumSince:(PrimalSharedLong * _Nullable)premiumSince legendProfile:(PrimalSharedPrimalLegendProfile * _Nullable)legendProfile __attribute__((swift_name("doCopy(primalName:cohort1:cohort2:tier:expiresAt:legendSince:premiumSince:legendProfile:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalPremiumInfo.Companion")))
@interface PrimalSharedPrimalPremiumInfoCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPrimalPremiumInfoCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ProfileData")))
@interface PrimalSharedProfileData : PrimalSharedBase
@property (readonly) NSString * _Nullable about __attribute__((swift_name("about")));
@property (readonly) NSArray<NSString *> *aboutHashtags __attribute__((swift_name("aboutHashtags")));
@property (readonly) NSArray<NSString *> *aboutUris __attribute__((swift_name("aboutUris")));
@property (readonly) PrimalSharedCdnImage * _Nullable avatarCdnImage __attribute__((swift_name("avatarCdnImage")));
@property (readonly) PrimalSharedCdnImage * _Nullable bannerCdnImage __attribute__((swift_name("bannerCdnImage")));
@property (readonly) NSArray<NSString *> *blossoms __attribute__((swift_name("blossoms")));
@property (readonly) PrimalSharedLong * _Nullable createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString * _Nullable displayName __attribute__((swift_name("displayName")));
@property (readonly) NSString * _Nullable handle __attribute__((swift_name("handle")));
@property (readonly) NSString * _Nullable internetIdentifier __attribute__((swift_name("internetIdentifier")));
@property (readonly) NSString * _Nullable lightningAddress __attribute__((swift_name("lightningAddress")));
@property (readonly) NSString * _Nullable lnUrlDecoded __attribute__((swift_name("lnUrlDecoded")));
@property (readonly) NSString * _Nullable metadataEventId __attribute__((swift_name("metadataEventId")));
@property (readonly) NSString * _Nullable metadataRawEvent __attribute__((swift_name("metadataRawEvent")));
@property (readonly) NSString * _Nullable primalName __attribute__((swift_name("primalName")));
@property (readonly) PrimalSharedPrimalPremiumInfo * _Nullable primalPremiumInfo __attribute__((swift_name("primalPremiumInfo")));
@property (readonly) NSString *profileId __attribute__((swift_name("profileId")));
@property (readonly) NSString * _Nullable website __attribute__((swift_name("website")));
- (instancetype)initWithProfileId:(NSString *)profileId metadataEventId:(NSString * _Nullable)metadataEventId createdAt:(PrimalSharedLong * _Nullable)createdAt metadataRawEvent:(NSString * _Nullable)metadataRawEvent handle:(NSString * _Nullable)handle displayName:(NSString * _Nullable)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier lightningAddress:(NSString * _Nullable)lightningAddress lnUrlDecoded:(NSString * _Nullable)lnUrlDecoded avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage bannerCdnImage:(PrimalSharedCdnImage * _Nullable)bannerCdnImage website:(NSString * _Nullable)website about:(NSString * _Nullable)about aboutUris:(NSArray<NSString *> *)aboutUris aboutHashtags:(NSArray<NSString *> *)aboutHashtags primalName:(NSString * _Nullable)primalName primalPremiumInfo:(PrimalSharedPrimalPremiumInfo * _Nullable)primalPremiumInfo blossoms:(NSArray<NSString *> *)blossoms __attribute__((swift_name("init(profileId:metadataEventId:createdAt:metadataRawEvent:handle:displayName:internetIdentifier:lightningAddress:lnUrlDecoded:avatarCdnImage:bannerCdnImage:website:about:aboutUris:aboutHashtags:primalName:primalPremiumInfo:blossoms:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedProfileData *)doCopyProfileId:(NSString *)profileId metadataEventId:(NSString * _Nullable)metadataEventId createdAt:(PrimalSharedLong * _Nullable)createdAt metadataRawEvent:(NSString * _Nullable)metadataRawEvent handle:(NSString * _Nullable)handle displayName:(NSString * _Nullable)displayName internetIdentifier:(NSString * _Nullable)internetIdentifier lightningAddress:(NSString * _Nullable)lightningAddress lnUrlDecoded:(NSString * _Nullable)lnUrlDecoded avatarCdnImage:(PrimalSharedCdnImage * _Nullable)avatarCdnImage bannerCdnImage:(PrimalSharedCdnImage * _Nullable)bannerCdnImage website:(NSString * _Nullable)website about:(NSString * _Nullable)about aboutUris:(NSArray<NSString *> *)aboutUris aboutHashtags:(NSArray<NSString *> *)aboutHashtags primalName:(NSString * _Nullable)primalName primalPremiumInfo:(PrimalSharedPrimalPremiumInfo * _Nullable)primalPremiumInfo blossoms:(NSArray<NSString *> *)blossoms __attribute__((swift_name("doCopy(profileId:metadataEventId:createdAt:metadataRawEvent:handle:displayName:internetIdentifier:lightningAddress:lnUrlDecoded:avatarCdnImage:bannerCdnImage:website:about:aboutUris:aboutHashtags:primalName:primalPremiumInfo:blossoms:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("ProfileRepository")))
@protocol PrimalSharedProfileRepository
@required

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchFollowersProfileId:(NSString *)profileId completionHandler:(void (^)(NSArray<PrimalSharedUserProfileSearchItem *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchFollowers(profileId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchFollowingProfileId:(NSString *)profileId completionHandler:(void (^)(NSArray<PrimalSharedUserProfileSearchItem *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchFollowing(profileId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchProfileProfileId:(NSString *)profileId completionHandler:(void (^)(PrimalSharedProfileData * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchProfile(profileId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchProfileIdPrimalName:(NSString *)primalName completionHandler:(void (^)(NSString * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchProfileId(primalName:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchProfilesProfileIds:(NSArray<NSString *> *)profileIds completionHandler:(void (^)(NSArray<PrimalSharedProfileData *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchProfiles(profileIds:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchUserProfileFollowedByProfileId:(NSString *)profileId userId:(NSString *)userId limit:(int32_t)limit completionHandler:(void (^)(NSArray<PrimalSharedProfileData *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("fetchUserProfileFollowedBy(profileId:userId:limit:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findProfileDataProfileIds:(NSArray<NSString *> *)profileIds completionHandler:(void (^)(NSArray<PrimalSharedProfileData *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("findProfileData(profileIds:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findProfileDataOrNullProfileId:(NSString *)profileId completionHandler:(void (^)(PrimalSharedProfileData * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("findProfileDataOrNull(profileId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)findProfileStatsProfileIds:(NSArray<NSString *> *)profileIds completionHandler:(void (^)(NSArray<PrimalSharedProfileStats *> * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("findProfileStats(profileIds:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)isUserFollowingUserId:(NSString *)userId targetUserId:(NSString *)targetUserId completionHandler:(void (^)(PrimalSharedBoolean * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("isUserFollowing(userId:targetUserId:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeProfileDataProfileId:(NSString *)profileId __attribute__((swift_name("observeProfileData(profileId:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeProfileDataProfileIds:(NSArray<NSString *> *)profileIds __attribute__((swift_name("observeProfileData(profileIds:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeProfileStatsProfileId:(NSString *)profileId __attribute__((swift_name("observeProfileStats(profileId:)")));

/**
 * @note This method converts instances of NostrPublishException, SignatureException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)reportAbuseUserId:(NSString *)userId reportType:(PrimalSharedReportType *)reportType profileId:(NSString *)profileId eventId:(NSString * _Nullable)eventId articleId:(NSString * _Nullable)articleId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("reportAbuse(userId:reportType:profileId:eventId:articleId:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ProfileStats")))
@interface PrimalSharedProfileStats : PrimalSharedBase
@property (readonly) PrimalSharedInt * _Nullable contentZapCount __attribute__((swift_name("contentZapCount")));
@property (readonly) PrimalSharedInt * _Nullable followers __attribute__((swift_name("followers")));
@property (readonly) PrimalSharedInt * _Nullable following __attribute__((swift_name("following")));
@property (readonly) PrimalSharedLong * _Nullable joinedAt __attribute__((swift_name("joinedAt")));
@property (readonly) PrimalSharedInt * _Nullable mediaCount __attribute__((swift_name("mediaCount")));
@property (readonly) PrimalSharedInt * _Nullable notesCount __attribute__((swift_name("notesCount")));
@property (readonly) NSString *profileId __attribute__((swift_name("profileId")));
@property (readonly) PrimalSharedInt * _Nullable readsCount __attribute__((swift_name("readsCount")));
@property (readonly) PrimalSharedInt * _Nullable relaysCount __attribute__((swift_name("relaysCount")));
@property (readonly) PrimalSharedInt * _Nullable repliesCount __attribute__((swift_name("repliesCount")));
@property (readonly) PrimalSharedLong * _Nullable totalReceivedSats __attribute__((swift_name("totalReceivedSats")));
@property (readonly) PrimalSharedLong * _Nullable totalReceivedZaps __attribute__((swift_name("totalReceivedZaps")));
- (instancetype)initWithProfileId:(NSString *)profileId following:(PrimalSharedInt * _Nullable)following followers:(PrimalSharedInt * _Nullable)followers notesCount:(PrimalSharedInt * _Nullable)notesCount readsCount:(PrimalSharedInt * _Nullable)readsCount mediaCount:(PrimalSharedInt * _Nullable)mediaCount repliesCount:(PrimalSharedInt * _Nullable)repliesCount relaysCount:(PrimalSharedInt * _Nullable)relaysCount totalReceivedZaps:(PrimalSharedLong * _Nullable)totalReceivedZaps contentZapCount:(PrimalSharedInt * _Nullable)contentZapCount totalReceivedSats:(PrimalSharedLong * _Nullable)totalReceivedSats joinedAt:(PrimalSharedLong * _Nullable)joinedAt __attribute__((swift_name("init(profileId:following:followers:notesCount:readsCount:mediaCount:repliesCount:relaysCount:totalReceivedZaps:contentZapCount:totalReceivedSats:joinedAt:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedProfileStats *)doCopyProfileId:(NSString *)profileId following:(PrimalSharedInt * _Nullable)following followers:(PrimalSharedInt * _Nullable)followers notesCount:(PrimalSharedInt * _Nullable)notesCount readsCount:(PrimalSharedInt * _Nullable)readsCount mediaCount:(PrimalSharedInt * _Nullable)mediaCount repliesCount:(PrimalSharedInt * _Nullable)repliesCount relaysCount:(PrimalSharedInt * _Nullable)relaysCount totalReceivedZaps:(PrimalSharedLong * _Nullable)totalReceivedZaps contentZapCount:(PrimalSharedInt * _Nullable)contentZapCount totalReceivedSats:(PrimalSharedLong * _Nullable)totalReceivedSats joinedAt:(PrimalSharedLong * _Nullable)joinedAt __attribute__((swift_name("doCopy(profileId:following:followers:notesCount:readsCount:mediaCount:repliesCount:relaysCount:totalReceivedZaps:contentZapCount:totalReceivedSats:joinedAt:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("NostrEventImporter")))
@protocol PrimalSharedNostrEventImporter
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)importEventsEvents:(NSArray<PrimalSharedNostrEvent *> *)events completionHandler:(void (^)(PrimalSharedBoolean * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("importEvents(events:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalPublishResult")))
@interface PrimalSharedPrimalPublishResult : PrimalSharedBase
@property (readonly) BOOL imported __attribute__((swift_name("imported")));
@property (readonly) PrimalSharedNostrEvent *nostrEvent __attribute__((swift_name("nostrEvent")));
- (instancetype)initWithNostrEvent:(PrimalSharedNostrEvent *)nostrEvent imported:(BOOL)imported __attribute__((swift_name("init(nostrEvent:imported:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPrimalPublishResult *)doCopyNostrEvent:(PrimalSharedNostrEvent *)nostrEvent imported:(BOOL)imported __attribute__((swift_name("doCopy(nostrEvent:imported:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("PrimalPublisher")))
@protocol PrimalSharedPrimalPublisher
@required

/**
 * @note This method converts instances of SignatureException, NostrPublishException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)signPublishImportNostrEventUnsignedNostrEvent:(PrimalSharedNostrUnsignedEvent *)unsignedNostrEvent outboxRelays:(NSArray<NSString *> *)outboxRelays completionHandler:(void (^)(PrimalSharedPrimalPublishResult * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("signPublishImportNostrEvent(unsignedNostrEvent:outboxRelays:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Article")))
@interface PrimalSharedArticle : PrimalSharedBase
@property (readonly) NSString *aTag __attribute__((swift_name("aTag")));
@property (readonly) NSString *articleId __attribute__((swift_name("articleId")));
@property (readonly) NSString *articleRawJson __attribute__((swift_name("articleRawJson")));
@property (readonly) PrimalSharedProfileData * _Nullable author __attribute__((swift_name("author")));
@property (readonly) NSString *authorId __attribute__((swift_name("authorId")));
@property (readonly) NSString * _Nullable authorMetadataId __attribute__((swift_name("authorMetadataId")));
@property (readonly) PrimalSharedPublicBookmark * _Nullable bookmark __attribute__((swift_name("bookmark")));
@property (readonly) NSString * _Nullable client __attribute__((swift_name("client")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString *eventId __attribute__((swift_name("eventId")));
@property (readonly) PrimalSharedNostrEventStats * _Nullable eventStats __attribute__((swift_name("eventStats")));
@property (readonly) NSArray<PrimalSharedEventZap *> *eventZaps __attribute__((swift_name("eventZaps")));
@property (readonly) NSArray<NSString *> *hashtags __attribute__((swift_name("hashtags")));
@property (readonly) NSArray<PrimalSharedHighlight *> *highlights __attribute__((swift_name("highlights")));
@property (readonly) PrimalSharedCdnImage * _Nullable imageCdnImage __attribute__((swift_name("imageCdnImage")));
@property (readonly) int64_t publishedAt __attribute__((swift_name("publishedAt")));
@property (readonly) NSString * _Nullable summary __attribute__((swift_name("summary")));
@property (readonly) NSString *title __attribute__((swift_name("title")));
@property (readonly) NSArray<NSString *> *uris __attribute__((swift_name("uris")));
@property (readonly) PrimalSharedNostrEventUserStats * _Nullable userEventStats __attribute__((swift_name("userEventStats")));
@property (readonly) PrimalSharedInt * _Nullable wordsCount __attribute__((swift_name("wordsCount")));
- (instancetype)initWithATag:(NSString *)aTag eventId:(NSString *)eventId articleId:(NSString *)articleId authorId:(NSString *)authorId createdAt:(int64_t)createdAt content:(NSString *)content title:(NSString *)title publishedAt:(int64_t)publishedAt articleRawJson:(NSString *)articleRawJson imageCdnImage:(PrimalSharedCdnImage * _Nullable)imageCdnImage summary:(NSString * _Nullable)summary authorMetadataId:(NSString * _Nullable)authorMetadataId wordsCount:(PrimalSharedInt * _Nullable)wordsCount uris:(NSArray<NSString *> *)uris hashtags:(NSArray<NSString *> *)hashtags author:(PrimalSharedProfileData * _Nullable)author eventStats:(PrimalSharedNostrEventStats * _Nullable)eventStats userEventStats:(PrimalSharedNostrEventUserStats * _Nullable)userEventStats eventZaps:(NSArray<PrimalSharedEventZap *> *)eventZaps bookmark:(PrimalSharedPublicBookmark * _Nullable)bookmark highlights:(NSArray<PrimalSharedHighlight *> *)highlights client:(NSString * _Nullable)client __attribute__((swift_name("init(aTag:eventId:articleId:authorId:createdAt:content:title:publishedAt:articleRawJson:imageCdnImage:summary:authorMetadataId:wordsCount:uris:hashtags:author:eventStats:userEventStats:eventZaps:bookmark:highlights:client:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedArticle *)doCopyATag:(NSString *)aTag eventId:(NSString *)eventId articleId:(NSString *)articleId authorId:(NSString *)authorId createdAt:(int64_t)createdAt content:(NSString *)content title:(NSString *)title publishedAt:(int64_t)publishedAt articleRawJson:(NSString *)articleRawJson imageCdnImage:(PrimalSharedCdnImage * _Nullable)imageCdnImage summary:(NSString * _Nullable)summary authorMetadataId:(NSString * _Nullable)authorMetadataId wordsCount:(PrimalSharedInt * _Nullable)wordsCount uris:(NSArray<NSString *> *)uris hashtags:(NSArray<NSString *> *)hashtags author:(PrimalSharedProfileData * _Nullable)author eventStats:(PrimalSharedNostrEventStats * _Nullable)eventStats userEventStats:(PrimalSharedNostrEventUserStats * _Nullable)userEventStats eventZaps:(NSArray<PrimalSharedEventZap *> *)eventZaps bookmark:(PrimalSharedPublicBookmark * _Nullable)bookmark highlights:(NSArray<PrimalSharedHighlight *> *)highlights client:(NSString * _Nullable)client __attribute__((swift_name("doCopy(aTag:eventId:articleId:authorId:createdAt:content:title:publishedAt:articleRawJson:imageCdnImage:summary:authorMetadataId:wordsCount:uris:hashtags:author:eventStats:userEventStats:eventZaps:bookmark:highlights:client:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("ArticleRepository")))
@protocol PrimalSharedArticleRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)deleteArticleByATagArticleATag:(NSString *)articleATag completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("deleteArticleByATag(articleATag:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)feedBySpecUserId:(NSString *)userId feedSpec:(NSString *)feedSpec __attribute__((swift_name("feedBySpec(userId:feedSpec:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchArticleAndCommentsUserId:(NSString *)userId articleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchArticleAndComments(userId:articleId:articleAuthorId:completionHandler:)")));

/**
 * @note This method converts instances of NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)fetchArticleHighlightsUserId:(NSString *)userId articleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("fetchArticleHighlights(userId:articleId:articleAuthorId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)getArticleByATagATag:(NSString *)aTag completionHandler:(void (^)(PrimalSharedArticle * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("getArticleByATag(aTag:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)observeArticleArticleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId completionHandler:(void (^)(id<PrimalSharedKotlinx_coroutines_coreFlow> _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("observeArticle(articleId:articleAuthorId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)observeArticleByCommentIdCommentNoteId:(NSString *)commentNoteId completionHandler:(void (^)(id<PrimalSharedKotlinx_coroutines_coreFlow> _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("observeArticleByCommentId(commentNoteId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)observeArticleByEventIdEventId:(NSString *)eventId articleAuthorId:(NSString *)articleAuthorId completionHandler:(void (^)(id<PrimalSharedKotlinx_coroutines_coreFlow> _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("observeArticleByEventId(eventId:articleAuthorId:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)observeArticleCommentsUserId:(NSString *)userId articleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId completionHandler:(void (^)(id<PrimalSharedKotlinx_coroutines_coreFlow> _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("observeArticleComments(userId:articleId:articleAuthorId:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Highlight")))
@interface PrimalSharedHighlight : PrimalSharedBase
@property (readonly) PrimalSharedProfileData * _Nullable author __attribute__((swift_name("author")));
@property (readonly) NSArray<PrimalSharedFeedPost *> *comments __attribute__((swift_name("comments")));
@property (readonly) PrimalSharedHighlightData *data __attribute__((swift_name("data")));
- (instancetype)initWithData:(PrimalSharedHighlightData *)data author:(PrimalSharedProfileData * _Nullable)author comments:(NSArray<PrimalSharedFeedPost *> *)comments __attribute__((swift_name("init(data:author:comments:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedHighlight *)doCopyData:(PrimalSharedHighlightData *)data author:(PrimalSharedProfileData * _Nullable)author comments:(NSArray<PrimalSharedFeedPost *> *)comments __attribute__((swift_name("doCopy(data:author:comments:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("HighlightData")))
@interface PrimalSharedHighlightData : PrimalSharedBase
@property (readonly) NSString * _Nullable alt __attribute__((swift_name("alt")));
@property (readonly) NSString *authorId __attribute__((swift_name("authorId")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) NSString * _Nullable context __attribute__((swift_name("context")));
@property (readonly) int64_t createdAt __attribute__((swift_name("createdAt")));
@property (readonly) NSString *highlightId __attribute__((swift_name("highlightId")));
@property (readonly) NSString * _Nullable referencedEventATag __attribute__((swift_name("referencedEventATag")));
@property (readonly) NSString * _Nullable referencedEventAuthorId __attribute__((swift_name("referencedEventAuthorId")));
- (instancetype)initWithHighlightId:(NSString *)highlightId authorId:(NSString *)authorId content:(NSString *)content context:(NSString * _Nullable)context alt:(NSString * _Nullable)alt referencedEventATag:(NSString * _Nullable)referencedEventATag referencedEventAuthorId:(NSString * _Nullable)referencedEventAuthorId createdAt:(int64_t)createdAt __attribute__((swift_name("init(highlightId:authorId:content:context:alt:referencedEventATag:referencedEventAuthorId:createdAt:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedHighlightData *)doCopyHighlightId:(NSString *)highlightId authorId:(NSString *)authorId content:(NSString *)content context:(NSString * _Nullable)context alt:(NSString * _Nullable)alt referencedEventATag:(NSString * _Nullable)referencedEventATag referencedEventAuthorId:(NSString * _Nullable)referencedEventAuthorId createdAt:(int64_t)createdAt __attribute__((swift_name("doCopy(highlightId:authorId:content:context:alt:referencedEventATag:referencedEventAuthorId:createdAt:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("HighlightRepository")))
@protocol PrimalSharedHighlightRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)getHighlightByIdHighlightId:(NSString *)highlightId completionHandler:(void (^)(PrimalSharedHighlight * _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("getHighlightById(highlightId:completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreFlow>)observeHighlightByIdHighlightId:(NSString *)highlightId __attribute__((swift_name("observeHighlightById(highlightId:)")));

/**
 * @note This method converts instances of NostrPublishException, SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)publishAndSaveHighlightUserId:(NSString *)userId content:(NSString *)content referencedEventATag:(NSString * _Nullable)referencedEventATag referencedEventAuthorTag:(NSString * _Nullable)referencedEventAuthorTag context:(NSString * _Nullable)context alt:(NSString *)alt createdAt:(int64_t)createdAt completionHandler:(void (^)(PrimalSharedNevent * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("publishAndSaveHighlight(userId:content:referencedEventATag:referencedEventAuthorTag:context:alt:createdAt:completionHandler:)")));

/**
 * @note This method converts instances of NostrPublishException, SignatureException, NetworkException, CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)publishDeleteHighlightUserId:(NSString *)userId highlightId:(NSString *)highlightId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("publishDeleteHighlight(userId:highlightId:completionHandler:)")));
@end

__attribute__((swift_name("UserDataCleanupRepository")))
@protocol PrimalSharedUserDataCleanupRepository
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)clearUserDataUserId:(NSString *)userId completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("clearUserData(userId:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PrimalInitializer")))
@interface PrimalSharedPrimalInitializer : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPrimalInitializer *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)primalInitializer __attribute__((swift_name("init()")));
- (void)doInit __attribute__((swift_name("doInit()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinByteArray")))
@interface PrimalSharedKotlinByteArray : PrimalSharedBase
@property (readonly) int32_t size __attribute__((swift_name("size")));
+ (instancetype)arrayWithSize:(int32_t)size __attribute__((swift_name("init(size:)")));
+ (instancetype)arrayWithSize:(int32_t)size init:(PrimalSharedByte *(^)(PrimalSharedInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (int8_t)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (PrimalSharedKotlinByteIterator *)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(int8_t)value __attribute__((swift_name("set(index:value:)")));
@end

@interface PrimalSharedKotlinByteArray (Extensions)
- (NSString *)toHex __attribute__((swift_name("toHex()")));
- (NSString *)toNpub __attribute__((swift_name("toNpub()")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="2.0")
 *   kotlin.uuid.ExperimentalUuidApi
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinUuid")))
@interface PrimalSharedKotlinUuid : PrimalSharedBase <PrimalSharedKotlinComparable>
@property (class, readonly, getter=companion) PrimalSharedKotlinUuidCompanion *companion __attribute__((swift_name("companion")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="2.1")
*/
- (int32_t)compareToOther:(PrimalSharedKotlinUuid *)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (PrimalSharedKotlinByteArray *)toByteArray __attribute__((swift_name("toByteArray()")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="2.1")
*/
- (NSString *)toHexDashString __attribute__((swift_name("toHexDashString()")));
- (NSString *)toHexString __attribute__((swift_name("toHexString()")));
- (id _Nullable)toLongsAction:(id _Nullable (^)(PrimalSharedLong *, PrimalSharedLong *))action __attribute__((swift_name("toLongs(action:)")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="2.1")
 *   kotlin.ExperimentalUnsignedTypes
*/
- (id)toUByteArray __attribute__((swift_name("toUByteArray()")));
- (id _Nullable)toULongsAction:(id _Nullable (^)(PrimalSharedULong *, PrimalSharedULong *))action __attribute__((swift_name("toULongs(action:)")));
@end

@interface PrimalSharedKotlinUuid (Extensions)
- (NSString *)toPrimalSubscriptionId __attribute__((swift_name("toPrimalSubscriptionId()")));
@end

@interface PrimalSharedPrimalEvent (Extensions)
- (id _Nullable)takeContentOrNull __attribute__((swift_name("takeContentOrNull()")));
@end

@interface PrimalSharedDvmFeed (Extensions)
- (NSString *)buildSpecSpecKind:(PrimalSharedFeedSpecKind *)specKind __attribute__((swift_name("buildSpec(specKind:)")));
@end

@interface PrimalSharedNaddr (Extensions)
- (NSString *)asATagValue __attribute__((swift_name("asATagValue()")));
- (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asPubkeyTagMarker:(NSString * _Nullable)marker __attribute__((swift_name("asPubkeyTag(marker:)")));
- (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asReplaceableEventTagMarker:(NSString * _Nullable)marker __attribute__((swift_name("asReplaceableEventTag(marker:)")));
@end

@interface PrimalSharedNevent (Extensions)
- (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asEventTagMarker:(NSString * _Nullable)marker __attribute__((swift_name("asEventTag(marker:)")));
- (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> * _Nullable)asPubkeyTagMarker:(NSString * _Nullable)marker __attribute__((swift_name("asPubkeyTag(marker:)")));
@end

@interface PrimalSharedNostrEvent (Extensions)
- (NSArray<NSString *> *)parseHashtags __attribute__((swift_name("parseHashtags()")));
- (NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)toNostrJsonObject __attribute__((swift_name("toNostrJsonObject()")));
@end

@interface PrimalSharedNostrEventKind (Extensions)
- (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asKindTag __attribute__((swift_name("asKindTag()")));
- (BOOL)isNotPrimalEventKind __attribute__((swift_name("isNotPrimalEventKind()")));
- (BOOL)isNotUnknown __attribute__((swift_name("isNotUnknown()")));
- (BOOL)isPrimalEventKind __attribute__((swift_name("isPrimalEventKind()")));
- (BOOL)isUnknown __attribute__((swift_name("isUnknown()")));
@end

@interface PrimalSharedNostrUnsignedEvent (Extensions)
- (PrimalSharedKotlinByteArray *)calculateEventId __attribute__((swift_name("calculateEventId()")));
- (PrimalSharedNostrEvent *)signOrThrowHexPrivateKey:(PrimalSharedKotlinByteArray *)hexPrivateKey __attribute__((swift_name("signOrThrow(hexPrivateKey:)")));
- (PrimalSharedNostrEvent *)signOrThrowNsec:(NSString *)nsec __attribute__((swift_name("signOrThrow(nsec:)")));
@end

@interface PrimalSharedSignResult (Extensions)
- (PrimalSharedNostrEvent * _Nullable)getOrNullOnFailure:(void (^ _Nullable)(PrimalSharedSignatureException *))onFailure __attribute__((swift_name("getOrNull(onFailure:)")));
- (PrimalSharedNostrEvent *)getOrThrowError:(PrimalSharedKotlinThrowable *)error __attribute__((swift_name("getOrThrow(error:)")));
- (PrimalSharedNostrEvent *)unwrapOrThrowOnFailure:(void (^ _Nullable)(PrimalSharedSignatureException *))onFailure __attribute__((swift_name("unwrapOrThrow(onFailure:)")));
@end

@interface PrimalSharedZapTarget (Extensions)
- (NSString *)lnUrlDecoded __attribute__((swift_name("lnUrlDecoded()")));
- (NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)toTags __attribute__((swift_name("toTags()")));
- (NSString *)userId __attribute__((swift_name("userId()")));
@end

@interface PrimalSharedPrimalPremiumInfo (Extensions)
- (PrimalSharedPrimalPremiumInfo *)plusPrimalPremiumInfo:(PrimalSharedPrimalPremiumInfo * _Nullable)primalPremiumInfo __attribute__((swift_name("plus(primalPremiumInfo:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ArticleUtilsKt")))
@interface PrimalSharedArticleUtilsKt : PrimalSharedBase
+ (int32_t)wordsCountToReadingTime:(PrimalSharedInt * _Nullable)receiver __attribute__((swift_name("wordsCountToReadingTime(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BlobDescriptorKt")))
@interface PrimalSharedBlobDescriptorKt : PrimalSharedBase
+ (PrimalSharedNip94Metadata *)toNip94Metadata:(NSArray<NSArray<NSString *> *> *)receiver __attribute__((swift_name("toNip94Metadata(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BlossomUtilsKt")))
@interface PrimalSharedBlossomUtilsKt : PrimalSharedBase
+ (NSArray<NSString *> *)resolveBlossomUrlsOriginalUrl:(NSString * _Nullable)originalUrl blossoms:(NSArray<NSString *> *)blossoms __attribute__((swift_name("resolveBlossomUrls(originalUrl:blossoms:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ConstantsKt")))
@interface PrimalSharedConstantsKt : PrimalSharedBase
@property (class, readonly) int32_t MAX_RELAY_HINTS __attribute__((swift_name("MAX_RELAY_HINTS")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentZapConfigItemKt")))
@interface PrimalSharedContentZapConfigItemKt : PrimalSharedBase
@property (class, readonly) NSArray<PrimalSharedContentZapConfigItem *> *DEFAULT_ZAP_CONFIG __attribute__((swift_name("DEFAULT_ZAP_CONFIG")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ContentZapDefaultKt")))
@interface PrimalSharedContentZapDefaultKt : PrimalSharedBase
@property (class, readonly) PrimalSharedContentZapDefault *DEFAULT_ZAP_DEFAULT __attribute__((swift_name("DEFAULT_ZAP_DEFAULT")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ConversionUtilsKt")))
@interface PrimalSharedConversionUtilsKt : PrimalSharedBase
+ (NSString *)assureValidNsec:(NSString *)receiver __attribute__((swift_name("assureValidNsec(_:)")));
+ (NSString *)bech32ToHexOrThrow:(NSString *)receiver __attribute__((swift_name("bech32ToHexOrThrow(_:)")));

/**
 * @note This method converts instances of IllegalArgumentException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
+ (PrimalSharedKotlinByteArray * _Nullable)bechToBytesOrThrow:(NSString *)receiver hrp:(NSString * _Nullable)hrp error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("bechToBytesOrThrow(_:hrp:)")));
+ (PrimalSharedKotlinPair<NSString *, NSString *> *)extractKeyPairFromPrivateKeyOrThrow:(NSString *)receiver __attribute__((swift_name("extractKeyPairFromPrivateKeyOrThrow(_:)")));
+ (NSString *)hexToNoteHrp:(NSString *)receiver __attribute__((swift_name("hexToNoteHrp(_:)")));
+ (NSString *)hexToNpubHrp:(NSString *)receiver __attribute__((swift_name("hexToNpubHrp(_:)")));
+ (NSString *)hexToNsecHrp:(NSString *)receiver __attribute__((swift_name("hexToNsecHrp(_:)")));
+ (NSString *)urlToLnUrlHrp:(NSString *)receiver __attribute__((swift_name("urlToLnUrlHrp(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedExtensionsKt")))
@interface PrimalSharedFeedExtensionsKt : PrimalSharedBase
@property (class, readonly) NSString *exploreMediaFeedSpec __attribute__((swift_name("exploreMediaFeedSpec")));
+ (NSString *)buildAdvancedSearchFeedSpec:(NSString * _Nullable)receiver __attribute__((swift_name("buildAdvancedSearchFeedSpec(_:)")));
+ (NSString *)buildAdvancedSearchNotesFeedSpecQuery:(NSString *)query __attribute__((swift_name("buildAdvancedSearchNotesFeedSpec(query:)")));
+ (NSString *)buildAdvancedSearchNotificationsFeedSpecQuery:(NSString *)query __attribute__((swift_name("buildAdvancedSearchNotificationsFeedSpec(query:)")));
+ (NSString *)buildAdvancedSearchReadsFeedSpecQuery:(NSString *)query __attribute__((swift_name("buildAdvancedSearchReadsFeedSpec(query:)")));
+ (NSString *)buildArticleBookmarksFeedSpecUserId:(NSString *)userId __attribute__((swift_name("buildArticleBookmarksFeedSpec(userId:)")));
+ (NSString *)buildLatestNotesUserFeedSpecUserId:(NSString *)userId __attribute__((swift_name("buildLatestNotesUserFeedSpec(userId:)")));
+ (NSString *)buildNotesBookmarksFeedSpecUserId:(NSString *)userId __attribute__((swift_name("buildNotesBookmarksFeedSpec(userId:)")));
+ (NSString *)buildReadsTopicFeedSpecHashtag:(NSString *)hashtag __attribute__((swift_name("buildReadsTopicFeedSpec(hashtag:)")));
+ (NSString * _Nullable)extractAdvancedSearchQuery:(NSString *)receiver __attribute__((swift_name("extractAdvancedSearchQuery(_:)")));
+ (NSString * _Nullable)extractPubkeyFromFeedSpec:(NSString *)receiver prefix:(NSString * _Nullable)prefix suffix:(NSString * _Nullable)suffix __attribute__((swift_name("extractPubkeyFromFeedSpec(_:prefix:suffix:)")));
+ (NSString * _Nullable)extractSimpleSearchQuery:(NSString *)receiver __attribute__((swift_name("extractSimpleSearchQuery(_:)")));
+ (NSString * _Nullable)extractTopicFromFeedSpec:(NSString *)receiver __attribute__((swift_name("extractTopicFromFeedSpec(_:)")));
+ (BOOL)isAdvancedSearchFeedSpec:(NSString *)receiver __attribute__((swift_name("isAdvancedSearchFeedSpec(_:)")));
+ (BOOL)isAudioSpec:(NSString *)receiver __attribute__((swift_name("isAudioSpec(_:)")));
+ (BOOL)isImageSpec:(NSString *)receiver __attribute__((swift_name("isImageSpec(_:)")));
+ (BOOL)isNotesBookmarkFeedSpec:(NSString *)receiver __attribute__((swift_name("isNotesBookmarkFeedSpec(_:)")));
+ (BOOL)isNotesFeedSpec:(NSString *)receiver __attribute__((swift_name("isNotesFeedSpec(_:)")));
+ (BOOL)isPremiumFeedSpec:(NSString *)receiver __attribute__((swift_name("isPremiumFeedSpec(_:)")));
+ (BOOL)isProfileAuthoredNoteRepliesFeedSpec:(NSString *)receiver __attribute__((swift_name("isProfileAuthoredNoteRepliesFeedSpec(_:)")));
+ (BOOL)isProfileAuthoredNotesFeedSpec:(NSString *)receiver __attribute__((swift_name("isProfileAuthoredNotesFeedSpec(_:)")));
+ (BOOL)isProfileNotesFeedSpec:(NSString *)receiver __attribute__((swift_name("isProfileNotesFeedSpec(_:)")));
+ (BOOL)isPubkeyFeedSpec:(NSString *)receiver prefix:(NSString * _Nullable)prefix suffix:(NSString * _Nullable)suffix __attribute__((swift_name("isPubkeyFeedSpec(_:prefix:suffix:)")));
+ (BOOL)isReadsFeedSpec:(NSString *)receiver __attribute__((swift_name("isReadsFeedSpec(_:)")));
+ (BOOL)isSearchFeedSpec:(NSString *)receiver __attribute__((swift_name("isSearchFeedSpec(_:)")));
+ (BOOL)isSimpleSearchFeedSpec:(NSString *)receiver __attribute__((swift_name("isSimpleSearchFeedSpec(_:)")));
+ (BOOL)isUserNotesFeedSpec:(NSString *)receiver __attribute__((swift_name("isUserNotesFeedSpec(_:)")));
+ (BOOL)isUserNotesLwrFeedSpec:(NSString *)receiver __attribute__((swift_name("isUserNotesLwrFeedSpec(_:)")));
+ (BOOL)isVideoSpec:(NSString *)receiver __attribute__((swift_name("isVideoSpec(_:)")));
+ (PrimalSharedFeedSpecKind * _Nullable)resolveFeedSpecKind:(NSString *)receiver __attribute__((swift_name("resolveFeedSpecKind(_:)")));
+ (BOOL)supportsNoteReposts:(NSString *)receiver __attribute__((swift_name("supportsNoteReposts(_:)")));
+ (BOOL)supportsUpwardsNotesPagination:(NSString *)receiver __attribute__((swift_name("supportsUpwardsNotesPagination(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("FeedKindKt")))
@interface PrimalSharedFeedKindKt : PrimalSharedBase
@property (class, readonly) NSString *FEED_KIND_DVM __attribute__((swift_name("FEED_KIND_DVM")));
@property (class, readonly) NSString *FEED_KIND_PRIMAL __attribute__((swift_name("FEED_KIND_PRIMAL")));
@property (class, readonly) NSString *FEED_KIND_SEARCH __attribute__((swift_name("FEED_KIND_SEARCH")));
@property (class, readonly) NSString *FEED_KIND_USER __attribute__((swift_name("FEED_KIND_USER")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("HashtagUtilsKt")))
@interface PrimalSharedHashtagUtilsKt : PrimalSharedBase
+ (NSArray<NSString *> *)parseHashtags:(NSString *)receiver __attribute__((swift_name("parseHashtags(_:)")));
+ (NSSet<NSString *> *)parseHashtagsFromNostrEventTags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("parseHashtagsFromNostrEventTags(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("JsonObjectMappersKt")))
@interface PrimalSharedJsonObjectMappersKt : PrimalSharedBase
+ (PrimalSharedNostrEvent * _Nullable)asNostrEventOrNull:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> * _Nullable)receiver __attribute__((swift_name("asNostrEventOrNull(_:)")));
+ (PrimalSharedPrimalEvent * _Nullable)asPrimalEventOrNull:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> * _Nullable)receiver __attribute__((swift_name("asPrimalEventOrNull(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("LightningExtKt")))
@interface PrimalSharedLightningExtKt : PrimalSharedBase
+ (NSString * _Nullable)decodeLNUrlOrNull:(NSString *)receiver __attribute__((swift_name("decodeLNUrlOrNull(_:)")));
+ (NSString * _Nullable)parseAsLNUrlOrNull:(NSString *)receiver __attribute__((swift_name("parseAsLNUrlOrNull(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NaddrKt")))
@interface PrimalSharedNaddrKt : PrimalSharedBase
+ (PrimalSharedNaddr * _Nullable)aTagToNaddr:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("aTagToNaddr(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrEventExtKt")))
@interface PrimalSharedNostrEventExtKt : PrimalSharedBase
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)toNostrJsonArray:(NSArray<PrimalSharedNostrEvent *> *)receiver __attribute__((swift_name("toNostrJsonArray(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessageExtKt")))
@interface PrimalSharedNostrIncomingMessageExtKt : PrimalSharedBase
+ (id<PrimalSharedKotlinx_coroutines_coreFlow>)filterByEventId:(id<PrimalSharedKotlinx_coroutines_coreFlow>)receiver id:(NSString *)id __attribute__((swift_name("filterByEventId(_:id:)")));
+ (id<PrimalSharedKotlinx_coroutines_coreFlow>)filterBySubscriptionId:(id<PrimalSharedKotlinx_coroutines_coreFlow>)receiver id:(NSString *)id __attribute__((swift_name("filterBySubscriptionId(_:id:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrIncomingMessageParserKt")))
@interface PrimalSharedNostrIncomingMessageParserKt : PrimalSharedBase
+ (PrimalSharedNostrIncomingMessage * _Nullable)parseIncomingMessage:(NSString *)receiver __attribute__((swift_name("parseIncomingMessage(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("NostrUriUtilsKt")))
@interface PrimalSharedNostrUriUtilsKt : PrimalSharedBase
+ (NSString *)clearAtSignFromNostrUris:(NSString *)receiver __attribute__((swift_name("clearAtSignFromNostrUris(_:)")));
+ (NSString * _Nullable)extractEventId:(NSString *)receiver __attribute__((swift_name("extractEventId(_:)")));
+ (NSString * _Nullable)extractNoteId:(NSString *)receiver __attribute__((swift_name("extractNoteId(_:)")));
+ (NSString * _Nullable)extractProfileId:(NSString *)receiver __attribute__((swift_name("extractProfileId(_:)")));
+ (BOOL)isNAddr:(NSString *)receiver __attribute__((swift_name("isNAddr(_:)")));
+ (BOOL)isNAddrUri:(NSString *)receiver __attribute__((swift_name("isNAddrUri(_:)")));
+ (BOOL)isNEvent:(NSString *)receiver __attribute__((swift_name("isNEvent(_:)")));
+ (BOOL)isNEventUri:(NSString *)receiver __attribute__((swift_name("isNEventUri(_:)")));
+ (BOOL)isNProfile:(NSString *)receiver __attribute__((swift_name("isNProfile(_:)")));
+ (BOOL)isNProfileUri:(NSString *)receiver __attribute__((swift_name("isNProfileUri(_:)")));
+ (BOOL)isNPub:(NSString *)receiver __attribute__((swift_name("isNPub(_:)")));
+ (BOOL)isNPubUri:(NSString *)receiver __attribute__((swift_name("isNPubUri(_:)")));
+ (BOOL)isNostrUri:(NSString *)receiver __attribute__((swift_name("isNostrUri(_:)")));
+ (BOOL)isNote:(NSString *)receiver __attribute__((swift_name("isNote(_:)")));
+ (BOOL)isNoteUri:(NSString *)receiver __attribute__((swift_name("isNoteUri(_:)")));
+ (PrimalSharedKotlinByteArray * _Nullable)nostrUriToBytes:(NSString *)receiver __attribute__((swift_name("nostrUriToBytes(_:)")));
+ (NSString * _Nullable)nostrUriToNoteId:(NSString *)receiver __attribute__((swift_name("nostrUriToNoteId(_:)")));
+ (PrimalSharedKotlinPair<NSString *, NSString *> *)nostrUriToNoteIdAndRelay:(NSString *)receiver __attribute__((swift_name("nostrUriToNoteIdAndRelay(_:)")));
+ (NSString * _Nullable)nostrUriToPubkey:(NSString *)receiver __attribute__((swift_name("nostrUriToPubkey(_:)")));
+ (PrimalSharedKotlinPair<NSString *, NSString *> *)nostrUriToPubkeyAndRelay:(NSString *)receiver __attribute__((swift_name("nostrUriToPubkeyAndRelay(_:)")));
+ (NSArray<NSString *> *)parseNostrUris:(NSString *)receiver __attribute__((swift_name("parseNostrUris(_:)")));
+ (PrimalSharedNaddr * _Nullable)takeAsNaddrOrNull:(NSString *)receiver __attribute__((swift_name("takeAsNaddrOrNull(_:)")));
+ (NSString * _Nullable)takeAsNaddrStringOrNull:(NSString *)receiver __attribute__((swift_name("takeAsNaddrStringOrNull(_:)")));
+ (PrimalSharedNevent * _Nullable)takeAsNeventOrNull:(NSString *)receiver __attribute__((swift_name("takeAsNeventOrNull(_:)")));
+ (NSString * _Nullable)takeAsNoteHexIdOrNull:(NSString *)receiver __attribute__((swift_name("takeAsNoteHexIdOrNull(_:)")));
+ (NSString * _Nullable)takeAsProfileHexIdOrNull:(NSString *)receiver __attribute__((swift_name("takeAsProfileHexIdOrNull(_:)")));
+ (NSString *)withNostrPrefix:(NSString *)receiver __attribute__((swift_name("withNostrPrefix(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("PremiumExtKt")))
@interface PrimalSharedPremiumExtKt : PrimalSharedBase
+ (BOOL)isPremiumFreeTier:(NSString * _Nullable)receiver __attribute__((swift_name("isPremiumFreeTier(_:)")));
+ (BOOL)isPremiumTier:(NSString * _Nullable)receiver __attribute__((swift_name("isPremiumTier(_:)")));
+ (BOOL)isPrimalLegendTier:(NSString * _Nullable)receiver __attribute__((swift_name("isPrimalLegendTier(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("RetryKt")))
@interface PrimalSharedRetryKt : PrimalSharedBase

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
+ (void)retryNetworkCallRetries:(int32_t)retries delay:(int64_t)delay onBeforeDelay:(void (^ _Nullable)(PrimalSharedNetworkException *))onBeforeDelay onBeforeTry:(void (^ _Nullable)(PrimalSharedInt *))onBeforeTry block:(id<PrimalSharedKotlinSuspendFunction0>)block completionHandler:(void (^)(id _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("retryNetworkCall(retries:delay:onBeforeDelay:onBeforeTry:block:completionHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringUtilsKt")))
@interface PrimalSharedStringUtilsKt : PrimalSharedBase
+ (BOOL)isPrimalIdentifier:(NSString * _Nullable)receiver __attribute__((swift_name("isPrimalIdentifier(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("StringUtilsKt_")))
@interface PrimalSharedStringUtilsKt_ : PrimalSharedBase
+ (NSString *)asEllipsizedNpub:(NSString *)receiver __attribute__((swift_name("asEllipsizedNpub(_:)")));
+ (NSString *)authorNameUiFriendlyDisplayName:(NSString * _Nullable)displayName name:(NSString * _Nullable)name pubkey:(NSString *)pubkey __attribute__((swift_name("authorNameUiFriendly(displayName:name:pubkey:)")));
+ (NSString *)formatNip05Identifier:(NSString *)receiver __attribute__((swift_name("formatNip05Identifier(_:)")));
+ (NSString *)usernameUiFriendlyDisplayName:(NSString * _Nullable)displayName name:(NSString * _Nullable)name pubkey:(NSString *)pubkey __attribute__((swift_name("usernameUiFriendly(displayName:name:pubkey:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("TagsKt")))
@interface PrimalSharedTagsKt : PrimalSharedBase
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asAltTag:(NSString *)receiver __attribute__((swift_name("asAltTag(_:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asContextTag:(NSString *)receiver __attribute__((swift_name("asContextTag(_:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asEventIdTag:(NSString *)receiver relayHint:(NSString * _Nullable)relayHint marker:(NSString * _Nullable)marker authorPubkey:(NSString * _Nullable)authorPubkey __attribute__((swift_name("asEventIdTag(_:relayHint:marker:authorPubkey:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asExpirationTag:(int64_t)receiver __attribute__((swift_name("asExpirationTag(_:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asHashtagTag:(NSString *)receiver __attribute__((swift_name("asHashtagTag(_:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asIdentifierTag:(NSString *)receiver __attribute__((swift_name("asIdentifierTag(_:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asPubkeyTag:(NSString *)receiver relayHint:(NSString * _Nullable)relayHint optional:(NSString * _Nullable)optional __attribute__((swift_name("asPubkeyTag(_:relayHint:optional:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asReplaceableEventTag:(NSString *)receiver relayHint:(NSString * _Nullable)relayHint marker:(NSString * _Nullable)marker __attribute__((swift_name("asReplaceableEventTag(_:relayHint:marker:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asServerTag:(NSString *)receiver __attribute__((swift_name("asServerTag(_:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asSha256Tag:(NSString *)receiver __attribute__((swift_name("asSha256Tag(_:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)asWordTag:(NSString *)receiver __attribute__((swift_name("asWordTag(_:)")));
+ (NSString * _Nullable)findFirstATag:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstATag(_:)")));
+ (NSString * _Nullable)findFirstAltDescription:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstAltDescription(_:)")));
+ (NSString * _Nullable)findFirstBolt11:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstBolt11(_:)")));
+ (NSString * _Nullable)findFirstClient:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstClient(_:)")));
+ (NSString * _Nullable)findFirstContextTag:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstContextTag(_:)")));
+ (NSString * _Nullable)findFirstDescription:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstDescription(_:)")));
+ (NSString * _Nullable)findFirstEventId:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstEventId(_:)")));
+ (NSString * _Nullable)findFirstIdentifier:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstIdentifier(_:)")));
+ (NSString * _Nullable)findFirstImage:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstImage(_:)")));
+ (NSString * _Nullable)findFirstProfileId:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstProfileId(_:)")));
+ (NSString * _Nullable)findFirstPublishedAt:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstPublishedAt(_:)")));
+ (NSString * _Nullable)findFirstReplaceableEventId:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstReplaceableEventId(_:)")));
+ (NSString * _Nullable)findFirstSummary:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstSummary(_:)")));
+ (NSString * _Nullable)findFirstTitle:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstTitle(_:)")));
+ (NSString * _Nullable)findFirstZapAmount:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstZapAmount(_:)")));
+ (NSString * _Nullable)findFirstZapRequest:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)receiver __attribute__((swift_name("findFirstZapRequest(_:)")));
+ (NSString * _Nullable)getPubkeyFromReplyOrRootTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("getPubkeyFromReplyOrRootTag(_:)")));
+ (NSString * _Nullable)getTagValueOrNull:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("getTagValueOrNull(_:)")));
+ (BOOL)hasMentionMarker:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("hasMentionMarker(_:)")));
+ (BOOL)hasReplyMarker:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("hasReplyMarker(_:)")));
+ (BOOL)hasRootMarker:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("hasRootMarker(_:)")));
+ (BOOL)isATag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isATag(_:)")));
+ (BOOL)isAltTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isAltTag(_:)")));
+ (BOOL)isAmountTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isAmountTag(_:)")));
+ (BOOL)isBolt11Tag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isBolt11Tag(_:)")));
+ (BOOL)isClientTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isClientTag(_:)")));
+ (BOOL)isContextTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isContextTag(_:)")));
+ (BOOL)isDescriptionTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isDescriptionTag(_:)")));
+ (BOOL)isEventIdTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isEventIdTag(_:)")));
+ (BOOL)isHashtagTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isHashtagTag(_:)")));
+ (BOOL)isIMetaTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isIMetaTag(_:)")));
+ (BOOL)isIdentifierTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isIdentifierTag(_:)")));
+ (BOOL)isImageTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isImageTag(_:)")));
+ (BOOL)isPubKeyTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isPubKeyTag(_:)")));
+ (BOOL)isPublishedAtTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isPublishedAtTag(_:)")));
+ (BOOL)isServerTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isServerTag(_:)")));
+ (BOOL)isSummaryTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isSummaryTag(_:)")));
+ (BOOL)isTitleTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isTitleTag(_:)")));
+ (BOOL)isWordTag:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("isWordTag(_:)")));
+ (NSSet<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)parseEventTags:(NSString *)receiver marker:(NSString * _Nullable)marker __attribute__((swift_name("parseEventTags(_:marker:)")));
+ (NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)parseHashtagTags:(NSString *)receiver __attribute__((swift_name("parseHashtagTags(_:)")));
+ (NSSet<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)parsePubkeyTags:(NSString *)receiver marker:(NSString * _Nullable)marker __attribute__((swift_name("parsePubkeyTags(_:marker:)")));
+ (NSSet<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)parseReplaceableEventTags:(NSString *)receiver marker:(NSString * _Nullable)marker __attribute__((swift_name("parseReplaceableEventTags(_:marker:)")));
+ (NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)removeTrailingEmptyStrings:(NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *)receiver __attribute__((swift_name("removeTrailingEmptyStrings(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("ValidationUtilsKt")))
@interface PrimalSharedValidationUtilsKt : PrimalSharedBase
+ (BOOL)isValidHex:(NSString *)receiver __attribute__((swift_name("isValidHex(_:)")));
+ (BOOL)isValidNostrPrivateKey:(NSString * _Nullable)receiver __attribute__((swift_name("isValidNostrPrivateKey(_:)")));
+ (BOOL)isValidNostrPublicKey:(NSString * _Nullable)receiver __attribute__((swift_name("isValidNostrPublicKey(_:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("__SkieSuspendWrappersKt")))
@interface PrimalShared__SkieSuspendWrappersKt : PrimalSharedBase
+ (void)Skie_Suspend__0__retryNetworkCallRetries:(int32_t)retries delay:(int64_t)delay onBeforeDelay:(void (^ _Nullable)(PrimalSharedNetworkException *))onBeforeDelay onBeforeTry:(void (^ _Nullable)(PrimalSharedInt *))onBeforeTry block:(id<PrimalSharedKotlinSuspendFunction0>)block suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__0__retryNetworkCall(retries:delay:onBeforeDelay:onBeforeTry:block:suspendHandler:)")));
+ (void)Skie_Suspend__100__fetchProfilesDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileIds:(NSArray<NSString *> *)profileIds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__100__fetchProfiles(dispatchReceiver:profileIds:suspendHandler:)")));
+ (void)Skie_Suspend__101__fetchUserProfileFollowedByDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileId:(NSString *)profileId userId:(NSString *)userId limit:(int32_t)limit suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__101__fetchUserProfileFollowedBy(dispatchReceiver:profileId:userId:limit:suspendHandler:)")));
+ (void)Skie_Suspend__102__findProfileDataDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileIds:(NSArray<NSString *> *)profileIds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__102__findProfileData(dispatchReceiver:profileIds:suspendHandler:)")));
+ (void)Skie_Suspend__103__findProfileDataOrNullDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileId:(NSString *)profileId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__103__findProfileDataOrNull(dispatchReceiver:profileId:suspendHandler:)")));
+ (void)Skie_Suspend__104__findProfileStatsDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileIds:(NSArray<NSString *> *)profileIds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__104__findProfileStats(dispatchReceiver:profileIds:suspendHandler:)")));
+ (void)Skie_Suspend__105__isUserFollowingDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver userId:(NSString *)userId targetUserId:(NSString *)targetUserId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__105__isUserFollowing(dispatchReceiver:userId:targetUserId:suspendHandler:)")));
+ (void)Skie_Suspend__106__reportAbuseDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver userId:(NSString *)userId reportType:(PrimalSharedReportType *)reportType profileId:(NSString *)profileId eventId:(NSString * _Nullable)eventId articleId:(NSString * _Nullable)articleId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__106__reportAbuse(dispatchReceiver:userId:reportType:profileId:eventId:articleId:suspendHandler:)")));
+ (void)Skie_Suspend__107__importEventsDispatchReceiver:(id<PrimalSharedNostrEventImporter>)dispatchReceiver events:(NSArray<PrimalSharedNostrEvent *> *)events suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__107__importEvents(dispatchReceiver:events:suspendHandler:)")));
+ (void)Skie_Suspend__108__signPublishImportNostrEventDispatchReceiver:(id<PrimalSharedPrimalPublisher>)dispatchReceiver unsignedNostrEvent:(PrimalSharedNostrUnsignedEvent *)unsignedNostrEvent outboxRelays:(NSArray<NSString *> *)outboxRelays suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__108__signPublishImportNostrEvent(dispatchReceiver:unsignedNostrEvent:outboxRelays:suspendHandler:)")));
+ (void)Skie_Suspend__109__deleteArticleByATagDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver articleATag:(NSString *)articleATag suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__109__deleteArticleByATag(dispatchReceiver:articleATag:suspendHandler:)")));
+ (void)Skie_Suspend__10__getBalanceDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__10__getBalance(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__110__fetchArticleAndCommentsDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver userId:(NSString *)userId articleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__110__fetchArticleAndComments(dispatchReceiver:userId:articleId:articleAuthorId:suspendHandler:)")));
+ (void)Skie_Suspend__111__fetchArticleHighlightsDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver userId:(NSString *)userId articleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__111__fetchArticleHighlights(dispatchReceiver:userId:articleId:articleAuthorId:suspendHandler:)")));
+ (void)Skie_Suspend__112__getArticleByATagDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver aTag:(NSString *)aTag suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__112__getArticleByATag(dispatchReceiver:aTag:suspendHandler:)")));
+ (void)Skie_Suspend__113__observeArticleDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver articleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__113__observeArticle(dispatchReceiver:articleId:articleAuthorId:suspendHandler:)")));
+ (void)Skie_Suspend__114__observeArticleByCommentIdDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver commentNoteId:(NSString *)commentNoteId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__114__observeArticleByCommentId(dispatchReceiver:commentNoteId:suspendHandler:)")));
+ (void)Skie_Suspend__115__observeArticleByEventIdDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver eventId:(NSString *)eventId articleAuthorId:(NSString *)articleAuthorId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__115__observeArticleByEventId(dispatchReceiver:eventId:articleAuthorId:suspendHandler:)")));
+ (void)Skie_Suspend__116__observeArticleCommentsDispatchReceiver:(id<PrimalSharedArticleRepository>)dispatchReceiver userId:(NSString *)userId articleId:(NSString *)articleId articleAuthorId:(NSString *)articleAuthorId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__116__observeArticleComments(dispatchReceiver:userId:articleId:articleAuthorId:suspendHandler:)")));
+ (void)Skie_Suspend__117__getHighlightByIdDispatchReceiver:(id<PrimalSharedHighlightRepository>)dispatchReceiver highlightId:(NSString *)highlightId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__117__getHighlightById(dispatchReceiver:highlightId:suspendHandler:)")));
+ (void)Skie_Suspend__118__publishAndSaveHighlightDispatchReceiver:(id<PrimalSharedHighlightRepository>)dispatchReceiver userId:(NSString *)userId content:(NSString *)content referencedEventATag:(NSString * _Nullable)referencedEventATag referencedEventAuthorTag:(NSString * _Nullable)referencedEventAuthorTag context:(NSString * _Nullable)context alt:(NSString *)alt createdAt:(int64_t)createdAt suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__118__publishAndSaveHighlight(dispatchReceiver:userId:content:referencedEventATag:referencedEventAuthorTag:context:alt:createdAt:suspendHandler:)")));
+ (void)Skie_Suspend__119__publishDeleteHighlightDispatchReceiver:(id<PrimalSharedHighlightRepository>)dispatchReceiver userId:(NSString *)userId highlightId:(NSString *)highlightId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__119__publishDeleteHighlight(dispatchReceiver:userId:highlightId:suspendHandler:)")));
+ (void)Skie_Suspend__11__getInfoDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__11__getInfo(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__120__clearUserDataDispatchReceiver:(id<PrimalSharedUserDataCleanupRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__120__clearUserData(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__121__headMediaDispatchReceiver:(id<PrimalSharedBlossomApi>)dispatchReceiver authorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__121__headMedia(dispatchReceiver:authorization:fileMetadata:suspendHandler:)")));
+ (void)Skie_Suspend__122__headUploadDispatchReceiver:(id<PrimalSharedBlossomApi>)dispatchReceiver authorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__122__headUpload(dispatchReceiver:authorization:fileMetadata:suspendHandler:)")));
+ (void)Skie_Suspend__123__putMediaDispatchReceiver:(id<PrimalSharedBlossomApi>)dispatchReceiver authorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata bufferedSource:(id<PrimalSharedOkioBufferedSource>)bufferedSource onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__123__putMedia(dispatchReceiver:authorization:fileMetadata:bufferedSource:onProgress:suspendHandler:)")));
+ (void)Skie_Suspend__124__putMirrorDispatchReceiver:(id<PrimalSharedBlossomApi>)dispatchReceiver authorization:(NSString *)authorization fileUrl:(NSString *)fileUrl suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__124__putMirror(dispatchReceiver:authorization:fileUrl:suspendHandler:)")));
+ (void)Skie_Suspend__125__putUploadDispatchReceiver:(id<PrimalSharedBlossomApi>)dispatchReceiver authorization:(NSString *)authorization fileMetadata:(PrimalSharedFileMetadata *)fileMetadata bufferedSource:(id<PrimalSharedOkioBufferedSource>)bufferedSource onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__125__putUpload(dispatchReceiver:authorization:fileMetadata:bufferedSource:onProgress:suspendHandler:)")));
+ (void)Skie_Suspend__126__provideBlossomServerListDispatchReceiver:(id<PrimalSharedBlossomServerListProvider>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__126__provideBlossomServerList(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__127__uploadDispatchReceiver:(PrimalSharedIosPrimalBlossomUploadService *)dispatchReceiver path:(NSString *)path userId:(NSString *)userId onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__127__upload(dispatchReceiver:path:userId:onProgress:suspendHandler:)")));
+ (void)Skie_Suspend__128__uploadDispatchReceiver:(PrimalSharedIosPrimalBlossomUploadService *)dispatchReceiver path:(NSString *)path userId:(NSString *)userId onSignRequested:(PrimalSharedNostrEvent *(^)(PrimalSharedNostrUnsignedEvent *))onSignRequested onProgress:(void (^ _Nullable)(PrimalSharedInt *, PrimalSharedInt *))onProgress suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__128__upload(dispatchReceiver:path:userId:onSignRequested:onProgress:suspendHandler:)")));
+ (void)Skie_Suspend__129__signNostrEventDispatchReceiver:(id<PrimalSharedNostrEventSignatureHandler>)dispatchReceiver unsignedNostrEvent:(PrimalSharedNostrUnsignedEvent *)unsignedNostrEvent suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__129__signNostrEvent(dispatchReceiver:unsignedNostrEvent:suspendHandler:)")));
+ (void)Skie_Suspend__12__listTransactionsDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver params:(PrimalSharedListTransactionsParams *)params suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__12__listTransactions(dispatchReceiver:params:suspendHandler:)")));
+ (void)Skie_Suspend__130__publishNostrEventDispatchReceiver:(id<PrimalSharedNostrEventPublisher>)dispatchReceiver nostrEvent:(PrimalSharedNostrEvent *)nostrEvent outboxRelays:(NSArray<NSString *> *)outboxRelays suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__130__publishNostrEvent(dispatchReceiver:nostrEvent:outboxRelays:suspendHandler:)")));
+ (void)Skie_Suspend__131__createOrNullDispatchReceiver:(id<PrimalSharedNostrZapperFactory>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__131__createOrNull(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__132__hasNextDispatchReceiver:(PrimalSharedSkieColdFlowIterator<id> *)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__132__hasNext(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__133__upgradeDispatchReceiver:(PrimalSharedKtor_httpOutgoingContentProtocolUpgrade *)dispatchReceiver input:(id<PrimalSharedKtor_ioByteReadChannel>)input output:(id<PrimalSharedKtor_ioByteWriteChannel>)output engineContext:(id<PrimalSharedKotlinCoroutineContext>)engineContext userContext:(id<PrimalSharedKotlinCoroutineContext>)userContext suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__133__upgrade(dispatchReceiver:input:output:engineContext:userContext:suspendHandler:)")));
+ (void)Skie_Suspend__134__flushDispatchReceiver:(id<PrimalSharedKtor_ioByteWriteChannel>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__134__flush(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__135__flushAndCloseDispatchReceiver:(id<PrimalSharedKtor_ioByteWriteChannel>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__135__flushAndClose(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__136__writeToDispatchReceiver:(PrimalSharedKtor_httpOutgoingContentWriteChannelContent *)dispatchReceiver channel:(id<PrimalSharedKtor_ioByteWriteChannel>)channel suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__136__writeTo(dispatchReceiver:channel:suspendHandler:)")));
+ (void)Skie_Suspend__13__lookupInvoiceDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver params:(PrimalSharedLookupInvoiceParams *)params suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__13__lookupInvoice(dispatchReceiver:params:suspendHandler:)")));
+ (void)Skie_Suspend__14__makeInvoiceDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver params:(PrimalSharedMakeInvoiceParams *)params suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__14__makeInvoice(dispatchReceiver:params:suspendHandler:)")));
+ (void)Skie_Suspend__15__multiPayInvoiceDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver params:(NSArray<PrimalSharedPayInvoiceParams *> *)params suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__15__multiPayInvoice(dispatchReceiver:params:suspendHandler:)")));
+ (void)Skie_Suspend__16__multiPayKeysendDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver params:(NSArray<PrimalSharedPayKeysendParams *> *)params suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__16__multiPayKeysend(dispatchReceiver:params:suspendHandler:)")));
+ (void)Skie_Suspend__17__payInvoiceDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver params:(PrimalSharedPayInvoiceParams *)params suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__17__payInvoice(dispatchReceiver:params:suspendHandler:)")));
+ (void)Skie_Suspend__18__payKeysendDispatchReceiver:(id<PrimalSharedNwcApi>)dispatchReceiver params:(PrimalSharedPayKeysendParams *)params suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__18__payKeysend(dispatchReceiver:params:suspendHandler:)")));
+ (void)Skie_Suspend__19__zapDispatchReceiver:(id<PrimalSharedNostrZapper>)dispatchReceiver data:(PrimalSharedZapRequestData *)data suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__19__zap(dispatchReceiver:data:suspendHandler:)")));
+ (void)Skie_Suspend__1__validateLightningAddressDispatchReceiver:(PrimalSharedLightningAddressChecker *)dispatchReceiver lud16:(NSString *)lud16 suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__1__validateLightningAddress(dispatchReceiver:lud16:suspendHandler:)")));
+ (void)Skie_Suspend__20__closeSubscriptionDispatchReceiver:(id<PrimalSharedPrimalApiClient>)dispatchReceiver subscriptionId:(NSString *)subscriptionId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__20__closeSubscription(dispatchReceiver:subscriptionId:suspendHandler:)")));
+ (void)Skie_Suspend__21__queryDispatchReceiver:(id<PrimalSharedPrimalApiClient>)dispatchReceiver message:(PrimalSharedPrimalCacheFilter *)message suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__21__query(dispatchReceiver:message:suspendHandler:)")));
+ (void)Skie_Suspend__22__subscribeDispatchReceiver:(id<PrimalSharedPrimalApiClient>)dispatchReceiver subscriptionId:(NSString *)subscriptionId message:(PrimalSharedPrimalCacheFilter *)message suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__22__subscribe(dispatchReceiver:subscriptionId:message:suspendHandler:)")));
+ (void)Skie_Suspend__23__collectDispatchReceiver:(id<PrimalSharedKotlinx_coroutines_coreFlow>)dispatchReceiver collector:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)collector suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__23__collect(dispatchReceiver:collector:suspendHandler:)")));
+ (void)Skie_Suspend__24__emitDispatchReceiver:(id<PrimalSharedKotlinx_coroutines_coreFlowCollector>)dispatchReceiver value:(id _Nullable)value suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__24__emit(dispatchReceiver:value:suspendHandler:)")));
+ (void)Skie_Suspend__25__unsubscribeDispatchReceiver:(PrimalSharedPrimalSocketSubscription<id> *)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__25__unsubscribe(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__26__invokeDispatchReceiver:(id<PrimalSharedKotlinSuspendFunction1>)dispatchReceiver p1:(id _Nullable)p1 suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__26__invoke(dispatchReceiver:p1:suspendHandler:)")));
+ (void)Skie_Suspend__27__closeDispatchReceiver:(id<PrimalSharedNostrSocketClient>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__27__close(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__28__ensureSocketConnectionOrThrowDispatchReceiver:(id<PrimalSharedNostrSocketClient>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__28__ensureSocketConnectionOrThrow(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__29__sendAUTHDispatchReceiver:(id<PrimalSharedNostrSocketClient>)dispatchReceiver signedEvent:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)signedEvent suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__29__sendAUTH(dispatchReceiver:signedEvent:suspendHandler:)")));
+ (void)Skie_Suspend__2__joinDispatchReceiver:(id<PrimalSharedKotlinx_coroutines_coreJob>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__2__join(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__30__sendCLOSEDispatchReceiver:(id<PrimalSharedNostrSocketClient>)dispatchReceiver subscriptionId:(NSString *)subscriptionId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__30__sendCLOSE(dispatchReceiver:subscriptionId:suspendHandler:)")));
+ (void)Skie_Suspend__31__sendCOUNTDispatchReceiver:(id<PrimalSharedNostrSocketClient>)dispatchReceiver data:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)data suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__31__sendCOUNT(dispatchReceiver:data:suspendHandler:)")));
+ (void)Skie_Suspend__32__sendEVENTDispatchReceiver:(id<PrimalSharedNostrSocketClient>)dispatchReceiver signedEvent:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)signedEvent suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__32__sendEVENT(dispatchReceiver:signedEvent:suspendHandler:)")));
+ (void)Skie_Suspend__33__sendREQDispatchReceiver:(id<PrimalSharedNostrSocketClient>)dispatchReceiver subscriptionId:(NSString *)subscriptionId data:(NSDictionary<NSString *, PrimalSharedKotlinx_serialization_jsonJsonElement *> *)data suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__33__sendREQ(dispatchReceiver:subscriptionId:data:suspendHandler:)")));
+ (void)Skie_Suspend__34__invokeDispatchReceiver:(id<PrimalSharedKotlinSuspendFunction0>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__34__invoke(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__35__addToBookmarksDispatchReceiver:(id<PrimalSharedPublicBookmarksRepository>)dispatchReceiver userId:(NSString *)userId bookmarkType:(PrimalSharedBookmarkType *)bookmarkType tagValue:(NSString *)tagValue forceUpdate:(BOOL)forceUpdate suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__35__addToBookmarks(dispatchReceiver:userId:bookmarkType:tagValue:forceUpdate:suspendHandler:)")));
+ (void)Skie_Suspend__36__fetchAndPersistBookmarksDispatchReceiver:(id<PrimalSharedPublicBookmarksRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__36__fetchAndPersistBookmarks(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__37__isBookmarkedDispatchReceiver:(id<PrimalSharedPublicBookmarksRepository>)dispatchReceiver tagValue:(NSString *)tagValue suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__37__isBookmarked(dispatchReceiver:tagValue:suspendHandler:)")));
+ (void)Skie_Suspend__38__removeFromBookmarksDispatchReceiver:(id<PrimalSharedPublicBookmarksRepository>)dispatchReceiver userId:(NSString *)userId bookmarkType:(PrimalSharedBookmarkType *)bookmarkType tagValue:(NSString *)tagValue forceUpdate:(BOOL)forceUpdate suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__38__removeFromBookmarks(dispatchReceiver:userId:bookmarkType:tagValue:forceUpdate:suspendHandler:)")));
+ (void)Skie_Suspend__39__deleteEventDispatchReceiver:(id<PrimalSharedEventInteractionRepository>)dispatchReceiver userId:(NSString *)userId eventIdentifier:(NSString *)eventIdentifier eventKind:(PrimalSharedNostrEventKind *)eventKind content:(NSString *)content relayHint:(NSString * _Nullable)relayHint suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__39__deleteEvent(dispatchReceiver:userId:eventIdentifier:eventKind:content:relayHint:suspendHandler:)")));
+ (void)Skie_Suspend__3__executeDispatchReceiver:(PrimalSharedKtor_utilsPipeline<id, id> *)dispatchReceiver context:(id)context subject:(id)subject suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__3__execute(dispatchReceiver:context:subject:suspendHandler:)")));
+ (void)Skie_Suspend__40__likeEventDispatchReceiver:(id<PrimalSharedEventInteractionRepository>)dispatchReceiver userId:(NSString *)userId eventId:(NSString *)eventId eventAuthorId:(NSString *)eventAuthorId optionalTags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)optionalTags suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__40__likeEvent(dispatchReceiver:userId:eventId:eventAuthorId:optionalTags:suspendHandler:)")));
+ (void)Skie_Suspend__41__repostEventDispatchReceiver:(id<PrimalSharedEventInteractionRepository>)dispatchReceiver userId:(NSString *)userId eventId:(NSString *)eventId eventKind:(int32_t)eventKind eventAuthorId:(NSString *)eventAuthorId eventRawNostrEvent:(NSString *)eventRawNostrEvent optionalTags:(NSArray<NSArray<PrimalSharedKotlinx_serialization_jsonJsonElement *> *> *)optionalTags suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__41__repostEvent(dispatchReceiver:userId:eventId:eventKind:eventAuthorId:eventRawNostrEvent:optionalTags:suspendHandler:)")));
+ (void)Skie_Suspend__42__zapEventDispatchReceiver:(id<PrimalSharedEventInteractionRepository>)dispatchReceiver userId:(NSString *)userId amountInSats:(uint64_t)amountInSats comment:(NSString *)comment target:(PrimalSharedZapTarget *)target zapRequestEvent:(PrimalSharedNostrEvent *)zapRequestEvent suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__42__zapEvent(dispatchReceiver:userId:amountInSats:comment:target:zapRequestEvent:suspendHandler:)")));
+ (void)Skie_Suspend__43__findRelaysByIdsDispatchReceiver:(id<PrimalSharedEventRelayHintsRepository>)dispatchReceiver eventIds:(NSArray<NSString *> *)eventIds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__43__findRelaysByIds(dispatchReceiver:eventIds:suspendHandler:)")));
+ (void)Skie_Suspend__44__fetchEventActionsDispatchReceiver:(id<PrimalSharedEventRepository>)dispatchReceiver eventId:(NSString *)eventId kind:(int32_t)kind suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__44__fetchEventActions(dispatchReceiver:eventId:kind:suspendHandler:)")));
+ (void)Skie_Suspend__45__fetchEventZapsDispatchReceiver:(id<PrimalSharedEventRepository>)dispatchReceiver userId:(NSString *)userId eventId:(NSString *)eventId limit:(int32_t)limit suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__45__fetchEventZaps(dispatchReceiver:userId:eventId:limit:suspendHandler:)")));
+ (void)Skie_Suspend__46__fetchFollowListDispatchReceiver:(id<PrimalSharedExploreRepository>)dispatchReceiver profileId:(NSString *)profileId identifier:(NSString *)identifier suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__46__fetchFollowList(dispatchReceiver:profileId:identifier:suspendHandler:)")));
+ (void)Skie_Suspend__47__fetchFollowListsDispatchReceiver:(id<PrimalSharedExploreRepository>)dispatchReceiver since:(PrimalSharedLong * _Nullable)since until:(PrimalSharedLong * _Nullable)until limit:(int32_t)limit offset:(PrimalSharedInt * _Nullable)offset suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__47__fetchFollowLists(dispatchReceiver:since:until:limit:offset:suspendHandler:)")));
+ (void)Skie_Suspend__48__fetchPopularUsersDispatchReceiver:(id<PrimalSharedExploreRepository>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__48__fetchPopularUsers(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__49__fetchTrendingPeopleDispatchReceiver:(id<PrimalSharedExploreRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__49__fetchTrendingPeople(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__4__invokeDispatchReceiver:(id<PrimalSharedKotlinSuspendFunction2>)dispatchReceiver p1:(id _Nullable)p1 p2:(id _Nullable)p2 suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__4__invoke(dispatchReceiver:p1:p2:suspendHandler:)")));
+ (void)Skie_Suspend__50__fetchTrendingTopicsDispatchReceiver:(id<PrimalSharedExploreRepository>)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__50__fetchTrendingTopics(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__51__fetchTrendingZapsDispatchReceiver:(id<PrimalSharedExploreRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__51__fetchTrendingZaps(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__52__searchUsersDispatchReceiver:(id<PrimalSharedExploreRepository>)dispatchReceiver query:(NSString *)query limit:(int32_t)limit suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__52__searchUsers(dispatchReceiver:query:limit:suspendHandler:)")));
+ (void)Skie_Suspend__53__addDvmFeedLocallyDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId dvmFeed:(PrimalSharedDvmFeed *)dvmFeed specKind:(PrimalSharedFeedSpecKind *)specKind suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__53__addDvmFeedLocally(dispatchReceiver:userId:dvmFeed:specKind:suspendHandler:)")));
+ (void)Skie_Suspend__54__addFeedLocallyDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId feedSpec:(NSString *)feedSpec title:(NSString *)title description:(NSString *)description feedSpecKind:(PrimalSharedFeedSpecKind *)feedSpecKind feedKind:(NSString *)feedKind suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__54__addFeedLocally(dispatchReceiver:userId:feedSpec:title:description:feedSpecKind:feedKind:suspendHandler:)")));
+ (void)Skie_Suspend__55__fetchAndPersistArticleFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__55__fetchAndPersistArticleFeeds(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__56__fetchAndPersistDefaultFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind givenDefaultFeeds:(NSArray<PrimalSharedPrimalFeed *> *)givenDefaultFeeds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__56__fetchAndPersistDefaultFeeds(dispatchReceiver:userId:specKind:givenDefaultFeeds:suspendHandler:)")));
+ (void)Skie_Suspend__57__fetchAndPersistNoteFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__57__fetchAndPersistNoteFeeds(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__58__fetchDefaultFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__58__fetchDefaultFeeds(dispatchReceiver:userId:specKind:suspendHandler:)")));
+ (void)Skie_Suspend__59__fetchRecommendedDvmFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind * _Nullable)specKind suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__59__fetchRecommendedDvmFeeds(dispatchReceiver:userId:specKind:suspendHandler:)")));
+ (void)Skie_Suspend__5__bodyDispatchReceiver:(PrimalSharedKtor_client_coreHttpClientCall *)dispatchReceiver info:(PrimalSharedKtor_utilsTypeInfo *)info suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__5__body(dispatchReceiver:info:suspendHandler:)")));
+ (void)Skie_Suspend__60__persistLocallyAndRemotelyUserFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind feeds:(NSArray<PrimalSharedPrimalFeed *> *)feeds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__60__persistLocallyAndRemotelyUserFeeds(dispatchReceiver:userId:specKind:feeds:suspendHandler:)")));
+ (void)Skie_Suspend__61__persistNewDefaultFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId specKind:(PrimalSharedFeedSpecKind *)specKind givenDefaultFeeds:(NSArray<PrimalSharedPrimalFeed *> *)givenDefaultFeeds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__61__persistNewDefaultFeeds(dispatchReceiver:userId:specKind:givenDefaultFeeds:suspendHandler:)")));
+ (void)Skie_Suspend__62__persistRemotelyAllLocalUserFeedsDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__62__persistRemotelyAllLocalUserFeeds(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__63__removeFeedLocallyDispatchReceiver:(id<PrimalSharedFeedsRepository>)dispatchReceiver userId:(NSString *)userId feedSpec:(NSString *)feedSpec suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__63__removeFeedLocally(dispatchReceiver:userId:feedSpec:suspendHandler:)")));
+ (void)Skie_Suspend__64__cacheEventsDispatchReceiver:(id<PrimalSharedCachingImportRepository>)dispatchReceiver nostrEvents:(NSArray<PrimalSharedNostrEvent *> *)nostrEvents primalEvents:(NSArray<PrimalSharedPrimalEvent *> *)primalEvents suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__64__cacheEvents(dispatchReceiver:nostrEvents:primalEvents:suspendHandler:)")));
+ (void)Skie_Suspend__65__cacheNostrEventsDispatchReceiver:(id<PrimalSharedCachingImportRepository>)dispatchReceiver events:(PrimalSharedKotlinArray<PrimalSharedNostrEvent *> *)events suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__65__cacheNostrEvents(dispatchReceiver:events:suspendHandler:)")));
+ (void)Skie_Suspend__66__cacheNostrEventsDispatchReceiver:(id<PrimalSharedCachingImportRepository>)dispatchReceiver events:(NSArray<PrimalSharedNostrEvent *> *)events suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__66__cacheNostrEvents(dispatchReceiver:events:suspendHandler:)")));
+ (void)Skie_Suspend__67__cachePrimalEventsDispatchReceiver:(id<PrimalSharedCachingImportRepository>)dispatchReceiver events:(PrimalSharedKotlinArray<PrimalSharedPrimalEvent *> *)events suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__67__cachePrimalEvents(dispatchReceiver:events:suspendHandler:)")));
+ (void)Skie_Suspend__68__cachePrimalEventsDispatchReceiver:(id<PrimalSharedCachingImportRepository>)dispatchReceiver events:(NSArray<PrimalSharedPrimalEvent *> *)events suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__68__cachePrimalEvents(dispatchReceiver:events:suspendHandler:)")));
+ (void)Skie_Suspend__69__loadEventLinksDispatchReceiver:(id<PrimalSharedEventUriRepository>)dispatchReceiver noteId:(NSString *)noteId types:(NSArray<PrimalSharedEventUriType *> *)types suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__69__loadEventLinks(dispatchReceiver:noteId:types:suspendHandler:)")));
+ (void)Skie_Suspend__6__bodyNullableDispatchReceiver:(PrimalSharedKtor_client_coreHttpClientCall *)dispatchReceiver info:(PrimalSharedKtor_utilsTypeInfo *)info suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__6__bodyNullable(dispatchReceiver:info:suspendHandler:)")));
+ (void)Skie_Suspend__70__fetchFollowConversationsDispatchReceiver:(id<PrimalSharedChatRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__70__fetchFollowConversations(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__71__fetchNewConversationMessagesDispatchReceiver:(id<PrimalSharedChatRepository>)dispatchReceiver userId:(NSString *)userId conversationUserId:(NSString *)conversationUserId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__71__fetchNewConversationMessages(dispatchReceiver:userId:conversationUserId:suspendHandler:)")));
+ (void)Skie_Suspend__72__fetchNonFollowsConversationsDispatchReceiver:(id<PrimalSharedChatRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__72__fetchNonFollowsConversations(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__73__markAllMessagesAsReadDispatchReceiver:(id<PrimalSharedChatRepository>)dispatchReceiver authorization:(PrimalSharedNostrEvent *)authorization suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__73__markAllMessagesAsRead(dispatchReceiver:authorization:suspendHandler:)")));
+ (void)Skie_Suspend__74__markConversationAsReadDispatchReceiver:(id<PrimalSharedChatRepository>)dispatchReceiver authorization:(PrimalSharedNostrEvent *)authorization conversationUserId:(NSString *)conversationUserId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__74__markConversationAsRead(dispatchReceiver:authorization:conversationUserId:suspendHandler:)")));
+ (void)Skie_Suspend__75__sendMessageDispatchReceiver:(id<PrimalSharedChatRepository>)dispatchReceiver userId:(NSString *)userId receiverId:(NSString *)receiverId text:(NSString *)text suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__75__sendMessage(dispatchReceiver:userId:receiverId:text:suspendHandler:)")));
+ (void)Skie_Suspend__76__fetchAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__76__fetchAndPersistMuteList(dispatchReceiver:userId:suspendHandler:)")));
+ (void)Skie_Suspend__77__muteHashtagAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId hashtag:(NSString *)hashtag suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__77__muteHashtagAndPersistMuteList(dispatchReceiver:userId:hashtag:suspendHandler:)")));
+ (void)Skie_Suspend__78__muteThreadAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId postId:(NSString *)postId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__78__muteThreadAndPersistMuteList(dispatchReceiver:userId:postId:suspendHandler:)")));
+ (void)Skie_Suspend__79__muteUserAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId mutedUserId:(NSString *)mutedUserId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__79__muteUserAndPersistMuteList(dispatchReceiver:userId:mutedUserId:suspendHandler:)")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
+ (void)Skie_Suspend__7__getResponseContentDispatchReceiver:(PrimalSharedKtor_client_coreHttpClientCall *)dispatchReceiver suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__7__getResponseContent(dispatchReceiver:suspendHandler:)")));
+ (void)Skie_Suspend__80__muteWordAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId word:(NSString *)word suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__80__muteWordAndPersistMuteList(dispatchReceiver:userId:word:suspendHandler:)")));
+ (void)Skie_Suspend__81__unmuteHashtagAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId hashtag:(NSString *)hashtag suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__81__unmuteHashtagAndPersistMuteList(dispatchReceiver:userId:hashtag:suspendHandler:)")));
+ (void)Skie_Suspend__82__unmuteThreadAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId postId:(NSString *)postId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__82__unmuteThreadAndPersistMuteList(dispatchReceiver:userId:postId:suspendHandler:)")));
+ (void)Skie_Suspend__83__unmuteUserAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId unmutedUserId:(NSString *)unmutedUserId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__83__unmuteUserAndPersistMuteList(dispatchReceiver:userId:unmutedUserId:suspendHandler:)")));
+ (void)Skie_Suspend__84__unmuteWordAndPersistMuteListDispatchReceiver:(id<PrimalSharedMutedItemRepository>)dispatchReceiver userId:(NSString *)userId word:(NSString *)word suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__84__unmuteWordAndPersistMuteList(dispatchReceiver:userId:word:suspendHandler:)")));
+ (void)Skie_Suspend__85__markAllNotificationsAsSeenDispatchReceiver:(id<PrimalSharedNotificationRepository>)dispatchReceiver authorization:(PrimalSharedNostrEvent *)authorization suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__85__markAllNotificationsAsSeen(dispatchReceiver:authorization:suspendHandler:)")));
+ (void)Skie_Suspend__86__deletePostByIdDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver postId:(NSString *)postId userId:(NSString *)userId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__86__deletePostById(dispatchReceiver:postId:userId:suspendHandler:)")));
+ (void)Skie_Suspend__87__fetchConversationDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver userId:(NSString *)userId noteId:(NSString *)noteId limit:(int32_t)limit suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__87__fetchConversation(dispatchReceiver:userId:noteId:limit:suspendHandler:)")));
+ (void)Skie_Suspend__88__fetchFeedPageSnapshotDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver userId:(NSString *)userId feedSpec:(NSString *)feedSpec notes:(NSString * _Nullable)notes until:(PrimalSharedLong * _Nullable)until since:(PrimalSharedLong * _Nullable)since order:(NSString * _Nullable)order limit:(int32_t)limit suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__88__fetchFeedPageSnapshot(dispatchReceiver:userId:feedSpec:notes:until:since:order:limit:suspendHandler:)")));
+ (void)Skie_Suspend__89__fetchRepliesDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver userId:(NSString *)userId noteId:(NSString *)noteId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__89__fetchReplies(dispatchReceiver:userId:noteId:suspendHandler:)")));
+ (void)Skie_Suspend__8__awaitContentDispatchReceiver:(id<PrimalSharedKtor_ioByteReadChannel>)dispatchReceiver min:(int32_t)min suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__8__awaitContent(dispatchReceiver:min:suspendHandler:)")));
+ (void)Skie_Suspend__90__findAllPostsByIdsDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver postIds:(NSArray<NSString *> *)postIds suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__90__findAllPostsByIds(dispatchReceiver:postIds:suspendHandler:)")));
+ (void)Skie_Suspend__91__findConversationDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver userId:(NSString *)userId noteId:(NSString *)noteId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__91__findConversation(dispatchReceiver:userId:noteId:suspendHandler:)")));
+ (void)Skie_Suspend__92__findNewestPostsDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver userId:(NSString *)userId feedDirective:(NSString *)feedDirective allowMutedThreads:(BOOL)allowMutedThreads limit:(int32_t)limit suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__92__findNewestPosts(dispatchReceiver:userId:feedDirective:allowMutedThreads:limit:suspendHandler:)")));
+ (void)Skie_Suspend__93__findPostsByIdDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver postId:(NSString *)postId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__93__findPostsById(dispatchReceiver:postId:suspendHandler:)")));
+ (void)Skie_Suspend__94__removeFeedSpecDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver userId:(NSString *)userId feedSpec:(NSString *)feedSpec suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__94__removeFeedSpec(dispatchReceiver:userId:feedSpec:suspendHandler:)")));
+ (void)Skie_Suspend__95__replaceFeedDispatchReceiver:(id<PrimalSharedFeedRepository>)dispatchReceiver userId:(NSString *)userId feedSpec:(NSString *)feedSpec snapshot:(PrimalSharedFeedPageSnapshot *)snapshot suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__95__replaceFeed(dispatchReceiver:userId:feedSpec:snapshot:suspendHandler:)")));
+ (void)Skie_Suspend__96__fetchFollowersDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileId:(NSString *)profileId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__96__fetchFollowers(dispatchReceiver:profileId:suspendHandler:)")));
+ (void)Skie_Suspend__97__fetchFollowingDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileId:(NSString *)profileId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__97__fetchFollowing(dispatchReceiver:profileId:suspendHandler:)")));
+ (void)Skie_Suspend__98__fetchProfileDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver profileId:(NSString *)profileId suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__98__fetchProfile(dispatchReceiver:profileId:suspendHandler:)")));
+ (void)Skie_Suspend__99__fetchProfileIdDispatchReceiver:(id<PrimalSharedProfileRepository>)dispatchReceiver primalName:(NSString *)primalName suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__99__fetchProfileId(dispatchReceiver:primalName:suspendHandler:)")));
+ (void)Skie_Suspend__9__executeDispatchReceiver:(id<PrimalSharedKtor_client_coreHttpClientEngine>)dispatchReceiver data:(PrimalSharedKtor_client_coreHttpRequestData *)data suspendHandler:(PrimalSharedSkie_SuspendHandler *)suspendHandler __attribute__((swift_name("Skie_Suspend__9__execute(dispatchReceiver:data:suspendHandler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("__SkieTypeExportsKt")))
@interface PrimalShared__SkieTypeExportsKt : PrimalSharedBase
+ (void)skieTypeExports_0P0:(PrimalSharedPaging_commonPagingData<id> *)p0 p1:(PrimalSharedKtor_httpOutgoingContentByteArrayContent *)p1 p2:(PrimalSharedKtor_httpOutgoingContentContentWrapper *)p2 p3:(PrimalSharedKtor_httpOutgoingContentNoContent *)p3 p4:(PrimalSharedKtor_httpOutgoingContentProtocolUpgrade *)p4 p5:(PrimalSharedKtor_httpOutgoingContentReadChannelContent *)p5 p6:(PrimalSharedKtor_httpOutgoingContentWriteChannelContent *)p6 p7:(id<PrimalSharedKotlinx_coroutines_coreSelectClause1>)p7 p8:(id<PrimalSharedKotlinx_coroutines_coreSelectClause2>)p8 p9:(PrimalSharedKotlinx_serialization_corePolymorphicKind *)p9 p10:(PrimalSharedKotlinx_serialization_corePolymorphicKindOPEN *)p10 p11:(PrimalSharedKotlinx_serialization_corePolymorphicKindSEALED *)p11 p12:(PrimalSharedKotlinx_serialization_corePrimitiveKind *)p12 p13:(PrimalSharedKotlinx_serialization_corePrimitiveKindBOOLEAN *)p13 p14:(PrimalSharedKotlinx_serialization_corePrimitiveKindBYTE *)p14 p15:(PrimalSharedKotlinx_serialization_corePrimitiveKindCHAR *)p15 p16:(PrimalSharedKotlinx_serialization_corePrimitiveKindDOUBLE *)p16 p17:(PrimalSharedKotlinx_serialization_corePrimitiveKindFLOAT *)p17 p18:(PrimalSharedKotlinx_serialization_corePrimitiveKindINT *)p18 p19:(PrimalSharedKotlinx_serialization_corePrimitiveKindLONG *)p19 p20:(PrimalSharedKotlinx_serialization_corePrimitiveKindSHORT *)p20 p21:(PrimalSharedKotlinx_serialization_corePrimitiveKindSTRING *)p21 p22:(PrimalSharedKotlinx_serialization_coreSerialKindCONTEXTUAL *)p22 p23:(PrimalSharedKotlinx_serialization_coreSerialKindENUM *)p23 p24:(PrimalSharedKotlinx_serialization_coreStructureKind *)p24 p25:(PrimalSharedKotlinx_serialization_coreStructureKindCLASS *)p25 p26:(PrimalSharedKotlinx_serialization_coreStructureKindLIST *)p26 p27:(PrimalSharedKotlinx_serialization_coreStructureKindMAP *)p27 p28:(PrimalSharedKotlinx_serialization_coreStructureKindOBJECT *)p28 p29:(PrimalSharedKotlinx_serialization_jsonJsonNull *)p29 p30:(PrimalSharedKotlinx_serialization_jsonJsonPrimitive *)p30 __attribute__((swift_name("skieTypeExports_0(p0:p1:p2:p3:p4:p5:p6:p7:p8:p9:p10:p11:p12:p13:p14:p15:p16:p17:p18:p19:p20:p21:p22:p23:p24:p25:p26:p27:p28:p29:p30:)")));
+ (void)skieTypeExports_1P0:(PrimalSharedPaging_commonLoadStateError *)p0 p1:(PrimalSharedPaging_commonLoadStateLoading *)p1 p2:(PrimalSharedPaging_commonLoadStateNotLoading *)p2 __attribute__((swift_name("skieTypeExports_1(p0:p1:p2:)")));
@end

__attribute__((swift_name("KotlinIllegalStateException")))
@interface PrimalSharedKotlinIllegalStateException : PrimalSharedKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.4")
*/
__attribute__((swift_name("KotlinCancellationException")))
@interface PrimalSharedKotlinCancellationException : PrimalSharedKotlinIllegalStateException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreRunnable")))
@protocol PrimalSharedKotlinx_coroutines_coreRunnable
@required
- (void)run __attribute__((swift_name("run()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinPair")))
@interface PrimalSharedKotlinPair<__covariant A, __covariant B> : PrimalSharedBase
@property (readonly) A _Nullable first __attribute__((swift_name("first")));
@property (readonly) B _Nullable second __attribute__((swift_name("second")));
- (instancetype)initWithFirst:(A _Nullable)first second:(B _Nullable)second __attribute__((swift_name("init(first:second:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKotlinPair<A, B> *)doCopyFirst:(A _Nullable)first second:(B _Nullable)second __attribute__((swift_name("doCopy(first:second:)")));
- (BOOL)equalsOther:(id _Nullable)other __attribute__((swift_name("equals(other:)")));
- (int32_t)hashCode __attribute__((swift_name("hashCode()")));
- (NSString *)toString __attribute__((swift_name("toString()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinEnumCompanion")))
@interface PrimalSharedKotlinEnumCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinEnumCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinArray")))
@interface PrimalSharedKotlinArray<T> : PrimalSharedBase
@property (readonly) int32_t size __attribute__((swift_name("size")));
+ (instancetype)arrayWithSize:(int32_t)size init:(T _Nullable (^)(PrimalSharedInt *))init __attribute__((swift_name("init(size:init:)")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (T _Nullable)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (id<PrimalSharedKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
- (void)setIndex:(int32_t)index value:(T _Nullable)value __attribute__((swift_name("set(index:value:)")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreSerializationStrategy")))
@protocol PrimalSharedKotlinx_serialization_coreSerializationStrategy
@required
- (void)serializeEncoder:(id<PrimalSharedKotlinx_serialization_coreEncoder>)encoder value:(id _Nullable)value __attribute__((swift_name("serialize(encoder:value:)")));
@property (readonly) id<PrimalSharedKotlinx_serialization_coreSerialDescriptor> descriptor __attribute__((swift_name("descriptor")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreDeserializationStrategy")))
@protocol PrimalSharedKotlinx_serialization_coreDeserializationStrategy
@required
- (id _Nullable)deserializeDecoder:(id<PrimalSharedKotlinx_serialization_coreDecoder>)decoder __attribute__((swift_name("deserialize(decoder:)")));
@property (readonly) id<PrimalSharedKotlinx_serialization_coreSerialDescriptor> descriptor __attribute__((swift_name("descriptor")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreKSerializer")))
@protocol PrimalSharedKotlinx_serialization_coreKSerializer <PrimalSharedKotlinx_serialization_coreSerializationStrategy, PrimalSharedKotlinx_serialization_coreDeserializationStrategy>
@required
@end

__attribute__((swift_name("OkioCloseable")))
@protocol PrimalSharedOkioCloseable
@required

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)closeAndReturnError:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("close()")));
@end

__attribute__((swift_name("OkioSource")))
@protocol PrimalSharedOkioSource <PrimalSharedOkioCloseable>
@required

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (int64_t)readSink:(PrimalSharedOkioBuffer *)sink byteCount:(int64_t)byteCount error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("read(sink:byteCount:)"))) __attribute__((swift_error(nonnull_error)));
- (PrimalSharedOkioTimeout *)timeout __attribute__((swift_name("timeout()")));
@end

__attribute__((swift_name("OkioBufferedSource")))
@protocol PrimalSharedOkioBufferedSource <PrimalSharedOkioSource>
@required
- (BOOL)exhausted __attribute__((swift_name("exhausted()")));
- (int64_t)indexOfB:(int8_t)b __attribute__((swift_name("indexOf(b:)")));
- (int64_t)indexOfBytes:(PrimalSharedOkioByteString *)bytes __attribute__((swift_name("indexOf(bytes:)")));
- (int64_t)indexOfB:(int8_t)b fromIndex:(int64_t)fromIndex __attribute__((swift_name("indexOf(b:fromIndex:)")));
- (int64_t)indexOfBytes:(PrimalSharedOkioByteString *)bytes fromIndex:(int64_t)fromIndex __attribute__((swift_name("indexOf(bytes:fromIndex:)")));
- (int64_t)indexOfB:(int8_t)b fromIndex:(int64_t)fromIndex toIndex:(int64_t)toIndex __attribute__((swift_name("indexOf(b:fromIndex:toIndex:)")));
- (int64_t)indexOfBytes:(PrimalSharedOkioByteString *)bytes fromIndex:(int64_t)fromIndex toIndex:(int64_t)toIndex __attribute__((swift_name("indexOf(bytes:fromIndex:toIndex:)")));
- (int64_t)indexOfElementTargetBytes:(PrimalSharedOkioByteString *)targetBytes __attribute__((swift_name("indexOfElement(targetBytes:)")));
- (int64_t)indexOfElementTargetBytes:(PrimalSharedOkioByteString *)targetBytes fromIndex:(int64_t)fromIndex __attribute__((swift_name("indexOfElement(targetBytes:fromIndex:)")));
- (id<PrimalSharedOkioBufferedSource>)peek __attribute__((swift_name("peek()")));
- (BOOL)rangeEqualsOffset:(int64_t)offset bytes:(PrimalSharedOkioByteString *)bytes __attribute__((swift_name("rangeEquals(offset:bytes:)")));
- (BOOL)rangeEqualsOffset:(int64_t)offset bytes:(PrimalSharedOkioByteString *)bytes bytesOffset:(int32_t)bytesOffset byteCount:(int32_t)byteCount __attribute__((swift_name("rangeEquals(offset:bytes:bytesOffset:byteCount:)")));
- (int32_t)readSink:(PrimalSharedKotlinByteArray *)sink __attribute__((swift_name("read(sink:)")));
- (int32_t)readSink:(PrimalSharedKotlinByteArray *)sink offset:(int32_t)offset byteCount:(int32_t)byteCount __attribute__((swift_name("read(sink:offset:byteCount:)")));
- (int64_t)readAllSink:(id<PrimalSharedOkioSink>)sink __attribute__((swift_name("readAll(sink:)")));
- (int8_t)readByte __attribute__((swift_name("readByte()")));
- (PrimalSharedKotlinByteArray *)readByteArray __attribute__((swift_name("readByteArray()")));
- (PrimalSharedKotlinByteArray *)readByteArrayByteCount:(int64_t)byteCount __attribute__((swift_name("readByteArray(byteCount:)")));
- (PrimalSharedOkioByteString *)readByteString __attribute__((swift_name("readByteString()")));
- (PrimalSharedOkioByteString *)readByteStringByteCount:(int64_t)byteCount __attribute__((swift_name("readByteString(byteCount:)")));
- (int64_t)readDecimalLong __attribute__((swift_name("readDecimalLong()")));
- (void)readFullySink:(PrimalSharedKotlinByteArray *)sink __attribute__((swift_name("readFully(sink:)")));
- (void)readFullySink:(PrimalSharedOkioBuffer *)sink byteCount:(int64_t)byteCount __attribute__((swift_name("readFully(sink:byteCount:)")));
- (int64_t)readHexadecimalUnsignedLong __attribute__((swift_name("readHexadecimalUnsignedLong()")));
- (int32_t)readInt __attribute__((swift_name("readInt()")));
- (int32_t)readIntLe __attribute__((swift_name("readIntLe()")));
- (int64_t)readLong __attribute__((swift_name("readLong()")));
- (int64_t)readLongLe __attribute__((swift_name("readLongLe()")));
- (int16_t)readShort __attribute__((swift_name("readShort()")));
- (int16_t)readShortLe __attribute__((swift_name("readShortLe()")));
- (NSString *)readUtf8 __attribute__((swift_name("readUtf8()")));
- (NSString *)readUtf8ByteCount:(int64_t)byteCount __attribute__((swift_name("readUtf8(byteCount:)")));
- (int32_t)readUtf8CodePoint __attribute__((swift_name("readUtf8CodePoint()")));
- (NSString * _Nullable)readUtf8Line __attribute__((swift_name("readUtf8Line()")));
- (NSString *)readUtf8LineStrict __attribute__((swift_name("readUtf8LineStrict()")));
- (NSString *)readUtf8LineStrictLimit:(int64_t)limit __attribute__((swift_name("readUtf8LineStrict(limit:)")));
- (BOOL)requestByteCount:(int64_t)byteCount __attribute__((swift_name("request(byteCount:)")));
- (void)requireByteCount:(int64_t)byteCount __attribute__((swift_name("require(byteCount:)")));
- (int32_t)selectOptions:(NSArray<PrimalSharedOkioByteString *> *)options __attribute__((swift_name("select(options:)")));
- (id _Nullable)selectOptions_:(NSArray<id> *)options __attribute__((swift_name("select(options_:)")));
- (void)skipByteCount:(int64_t)byteCount __attribute__((swift_name("skip(byteCount:)")));
@property (readonly) PrimalSharedOkioBuffer *buffer __attribute__((swift_name("buffer")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable(with=NormalClass(value=kotlinx/serialization/json/JsonElementSerializer))
*/
__attribute__((swift_name("Kotlinx_serialization_jsonJsonElement")))
@interface PrimalSharedKotlinx_serialization_jsonJsonElement : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedKotlinx_serialization_jsonJsonElementCompanion *companion __attribute__((swift_name("companion")));
@end

__attribute__((swift_name("UtilsDispatcherProvider")))
@protocol PrimalSharedUtilsDispatcherProvider
@required
- (PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher *)io __attribute__((swift_name("io()")));
- (PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher *)main __attribute__((swift_name("main()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreCoroutineScope")))
@protocol PrimalSharedKotlinx_coroutines_coreCoroutineScope
@required
@property (readonly) id<PrimalSharedKotlinCoroutineContext> coroutineContext __attribute__((swift_name("coroutineContext")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="2.0")
*/
__attribute__((swift_name("KotlinAutoCloseable")))
@protocol PrimalSharedKotlinAutoCloseable
@required
- (void)close __attribute__((swift_name("close_()")));
@end

__attribute__((swift_name("Ktor_ioCloseable")))
@protocol PrimalSharedKtor_ioCloseable <PrimalSharedKotlinAutoCloseable>
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpClient")))
@interface PrimalSharedKtor_client_coreHttpClient : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreCoroutineScope, PrimalSharedKtor_ioCloseable>
@property (readonly) id<PrimalSharedKtor_utilsAttributes> attributes __attribute__((swift_name("attributes")));
@property (readonly) id<PrimalSharedKotlinCoroutineContext> coroutineContext __attribute__((swift_name("coroutineContext")));
@property (readonly) id<PrimalSharedKtor_client_coreHttpClientEngine> engine __attribute__((swift_name("engine")));
@property (readonly) PrimalSharedKtor_client_coreHttpClientEngineConfig *engineConfig __attribute__((swift_name("engineConfig")));
@property (readonly) PrimalSharedKtor_eventsEvents *monitor __attribute__((swift_name("monitor")));
@property (readonly) PrimalSharedKtor_client_coreHttpReceivePipeline *receivePipeline __attribute__((swift_name("receivePipeline")));
@property (readonly) PrimalSharedKtor_client_coreHttpRequestPipeline *requestPipeline __attribute__((swift_name("requestPipeline")));
@property (readonly) PrimalSharedKtor_client_coreHttpResponsePipeline *responsePipeline __attribute__((swift_name("responsePipeline")));
@property (readonly) PrimalSharedKtor_client_coreHttpSendPipeline *sendPipeline __attribute__((swift_name("sendPipeline")));
- (instancetype)initWithEngine:(id<PrimalSharedKtor_client_coreHttpClientEngine>)engine userConfig:(PrimalSharedKtor_client_coreHttpClientConfig<PrimalSharedKtor_client_coreHttpClientEngineConfig *> *)userConfig __attribute__((swift_name("init(engine:userConfig:)"))) __attribute__((objc_designated_initializer));
- (void)close __attribute__((swift_name("close_()")));
- (PrimalSharedKtor_client_coreHttpClient *)configBlock:(void (^)(PrimalSharedKtor_client_coreHttpClientConfig<id> *))block __attribute__((swift_name("config(block:)")));
- (BOOL)isSupportedCapability:(id<PrimalSharedKtor_client_coreHttpClientEngineCapability>)capability __attribute__((swift_name("isSupported(capability:)")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinFunction")))
@protocol PrimalSharedKotlinFunction
@required
@end

__attribute__((swift_name("KotlinSuspendFunction1")))
@protocol PrimalSharedKotlinSuspendFunction1 <PrimalSharedKotlinFunction>
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)invokeP1:(id _Nullable)p1 completionHandler:(void (^)(id _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("invoke(p1:completionHandler:)")));
@end

__attribute__((swift_name("KotlinComparator")))
@protocol PrimalSharedKotlinComparator
@required
- (int32_t)compareA:(id _Nullable)a b:(id _Nullable)b __attribute__((swift_name("compare(a:b:)")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable(with=NormalClass(value=kotlinx/datetime/serializers/InstantIso8601Serializer))
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_datetimeInstant")))
@interface PrimalSharedKotlinx_datetimeInstant : PrimalSharedBase <PrimalSharedKotlinComparable>
@property (class, readonly, getter=companion) PrimalSharedKotlinx_datetimeInstantCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t epochSeconds __attribute__((swift_name("epochSeconds")));
@property (readonly) int32_t nanosecondsOfSecond __attribute__((swift_name("nanosecondsOfSecond")));
- (int32_t)compareToOther:(PrimalSharedKotlinx_datetimeInstant *)other __attribute__((swift_name("compareTo(other:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (PrimalSharedKotlinx_datetimeInstant *)minusDuration:(int64_t)duration __attribute__((swift_name("minus(duration:)")));
- (int64_t)minusOther:(PrimalSharedKotlinx_datetimeInstant *)other __attribute__((swift_name("minus(other:)")));
- (PrimalSharedKotlinx_datetimeInstant *)plusDuration:(int64_t)duration __attribute__((swift_name("plus(duration:)")));
- (int64_t)toEpochMilliseconds __attribute__((swift_name("toEpochMilliseconds()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinIllegalArgumentException")))
@interface PrimalSharedKotlinIllegalArgumentException : PrimalSharedKotlinRuntimeException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
@end

__attribute__((swift_name("KotlinIterable")))
@protocol PrimalSharedKotlinIterable
@required
- (id<PrimalSharedKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
@end

__attribute__((swift_name("KotlinIntProgression")))
@interface PrimalSharedKotlinIntProgression : PrimalSharedBase <PrimalSharedKotlinIterable>
@property (class, readonly, getter=companion) PrimalSharedKotlinIntProgressionCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t first __attribute__((swift_name("first")));
@property (readonly) int32_t last __attribute__((swift_name("last")));
@property (readonly) int32_t step __attribute__((swift_name("step")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (PrimalSharedKotlinIntIterator *)iterator __attribute__((swift_name("iterator()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinClosedRange")))
@protocol PrimalSharedKotlinClosedRange
@required
- (BOOL)containsValue:(id)value __attribute__((swift_name("contains(value:)")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
@property (readonly) id endInclusive __attribute__((swift_name("endInclusive")));
@property (readonly) id start __attribute__((swift_name("start")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.9")
*/
__attribute__((swift_name("KotlinOpenEndRange")))
@protocol PrimalSharedKotlinOpenEndRange
@required
- (BOOL)containsValue_:(id)value __attribute__((swift_name("contains(value_:)")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
@property (readonly) id endExclusive __attribute__((swift_name("endExclusive")));
@property (readonly) id start __attribute__((swift_name("start")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinIntRange")))
@interface PrimalSharedKotlinIntRange : PrimalSharedKotlinIntProgression <PrimalSharedKotlinClosedRange, PrimalSharedKotlinOpenEndRange>
@property (class, readonly, getter=companion) PrimalSharedKotlinIntRangeCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedInt *endExclusive __attribute__((swift_name("endExclusive"))) __attribute__((deprecated("Can throw an exception when it's impossible to represent the value with Int type, for example, when the range includes MAX_VALUE. It's recommended to use 'endInclusive' property that doesn't throw.")));
@property (readonly) PrimalSharedInt *endInclusive __attribute__((swift_name("endInclusive")));
@property (readonly) PrimalSharedInt *start __attribute__((swift_name("start")));
- (instancetype)initWithStart:(int32_t)start endInclusive:(int32_t)endInclusive __attribute__((swift_name("init(start:endInclusive:)"))) __attribute__((objc_designated_initializer));
- (BOOL)containsValue:(PrimalSharedInt *)value __attribute__((swift_name("contains(value:)")));
- (BOOL)containsValue_:(PrimalSharedInt *)value __attribute__((swift_name("contains(value_:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.9")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinTriple")))
@interface PrimalSharedKotlinTriple<__covariant A, __covariant B, __covariant C> : PrimalSharedBase
@property (readonly) A _Nullable first __attribute__((swift_name("first")));
@property (readonly) B _Nullable second __attribute__((swift_name("second")));
@property (readonly) C _Nullable third __attribute__((swift_name("third")));
- (instancetype)initWithFirst:(A _Nullable)first second:(B _Nullable)second third:(C _Nullable)third __attribute__((swift_name("init(first:second:third:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKotlinTriple<A, B, C> *)doCopyFirst:(A _Nullable)first second:(B _Nullable)second third:(C _Nullable)third __attribute__((swift_name("doCopy(first:second:third:)")));
- (BOOL)equalsOther:(id _Nullable)other __attribute__((swift_name("equals(other:)")));
- (int32_t)hashCode __attribute__((swift_name("hashCode()")));
- (NSString *)toString __attribute__((swift_name("toString()")));
@end

__attribute__((swift_name("BignumBigNumber")))
@protocol PrimalSharedBignumBigNumber
@required
- (id<PrimalSharedBignumBigNumber>)abs __attribute__((swift_name("abs()")));
- (id<PrimalSharedBignumBigNumber>)addOther:(id<PrimalSharedBignumBigNumber>)other __attribute__((swift_name("add(other:)")));
- (int32_t)compareToOther_:(id)other __attribute__((swift_name("compareTo(other_:)")));
- (id<PrimalSharedBignumBigNumber>)divideOther:(id<PrimalSharedBignumBigNumber>)other __attribute__((swift_name("divide(other:)")));
- (PrimalSharedKotlinPair<id<PrimalSharedBignumBigNumber>, id<PrimalSharedBignumBigNumber>> *)divideAndRemainderOther:(id<PrimalSharedBignumBigNumber>)other __attribute__((swift_name("divideAndRemainder(other:)")));
- (id<PrimalSharedBignumBigNumberCreator>)getCreator __attribute__((swift_name("getCreator()")));
- (BOOL)isZero __attribute__((swift_name("isZero()")));
- (id<PrimalSharedBignumBigNumber>)multiplyOther:(id<PrimalSharedBignumBigNumber>)other __attribute__((swift_name("multiply(other:)")));
- (id<PrimalSharedBignumBigNumber>)negate __attribute__((swift_name("negate()")));
- (int64_t)numberOfDecimalDigits __attribute__((swift_name("numberOfDecimalDigits()")));
- (id<PrimalSharedBignumBigNumber>)powExponent:(int32_t)exponent __attribute__((swift_name("pow(exponent:)")));
- (id<PrimalSharedBignumBigNumber>)powExponent_:(int64_t)exponent __attribute__((swift_name("pow(exponent_:)")));
- (id<PrimalSharedBignumBigNumber>)remainderOther:(id<PrimalSharedBignumBigNumber>)other __attribute__((swift_name("remainder(other:)")));
- (void)secureOverwrite __attribute__((swift_name("secureOverwrite()")));
- (int32_t)signum __attribute__((swift_name("signum()")));
- (id<PrimalSharedBignumBigNumber>)subtractOther:(id<PrimalSharedBignumBigNumber>)other __attribute__((swift_name("subtract(other:)")));
- (NSString *)toStringBase:(int32_t)base __attribute__((swift_name("toString(base:)")));
- (id<PrimalSharedBignumBigNumber>)unaryMinus __attribute__((swift_name("unaryMinus()")));
@property (readonly) BOOL isNegative __attribute__((swift_name("isNegative")));
@property (readonly) BOOL isPositive __attribute__((swift_name("isPositive")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumBigDecimal")))
@interface PrimalSharedBignumBigDecimal : PrimalSharedBase <PrimalSharedBignumBigNumber, PrimalSharedKotlinComparable>
@property (class, readonly, getter=companion) PrimalSharedBignumBigDecimalCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedBignumDecimalMode * _Nullable decimalMode __attribute__((swift_name("decimalMode")));
@property (readonly) int64_t exponent __attribute__((swift_name("exponent")));
@property (readonly) int64_t precision __attribute__((swift_name("precision")));
@property (readonly) int64_t precisionLimit __attribute__((swift_name("precisionLimit")));
@property (readonly) PrimalSharedBignumRoundingMode *roundingMode __attribute__((swift_name("roundingMode")));
@property (readonly) int64_t scale __attribute__((swift_name("scale")));
@property (readonly) PrimalSharedBignumBigInteger *significand __attribute__((swift_name("significand")));
@property (readonly) BOOL usingScale __attribute__((swift_name("usingScale")));
- (PrimalSharedBignumBigDecimal *)abs __attribute__((swift_name("abs()")));
- (PrimalSharedBignumBigDecimal *)addOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("add(other:)")));
- (PrimalSharedBignumBigDecimal *)addOther:(PrimalSharedBignumBigDecimal *)other decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("add(other:decimalMode:)")));
- (int8_t)byteValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("byteValue(exactRequired:)")));
- (PrimalSharedBignumBigDecimal *)ceil __attribute__((swift_name("ceil()")));
- (int32_t)compareOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("compare(other:)")));
- (int32_t)compareToOther:(id)other __attribute__((swift_name("compareTo(other:)")));
- (int32_t)compareToOther_:(id)other __attribute__((swift_name("compareTo(other_:)")));
- (PrimalSharedBignumBigDecimal *)doCopySignificand:(PrimalSharedBignumBigInteger *)significand exponent:(int64_t)exponent decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("doCopy(significand:exponent:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)dec __attribute__((swift_name("dec()")));
- (PrimalSharedBignumBigDecimal *)divOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("div(other:)")));
- (PrimalSharedBignumBigDecimal *)divideOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("divide(other:)")));
- (PrimalSharedBignumBigDecimal *)divideOther:(PrimalSharedBignumBigDecimal *)other decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("divide(other:decimalMode:)")));
- (PrimalSharedKotlinPair<PrimalSharedBignumBigDecimal *, PrimalSharedBignumBigDecimal *> *)divideAndRemainderOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("divideAndRemainder(other:)")));
- (PrimalSharedKotlinPair<PrimalSharedBignumBigDecimal *, PrimalSharedBignumBigDecimal *> *)divremOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("divrem(other:)")));
- (double)doubleValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("doubleValue(exactRequired:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (float)floatValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("floatValue(exactRequired:)")));
- (PrimalSharedBignumBigDecimal *)floor __attribute__((swift_name("floor()")));
- (id<PrimalSharedBignumBigNumberCreator>)getCreator __attribute__((swift_name("getCreator()")));
- (PrimalSharedBignumBigDecimal *)getInstance __attribute__((swift_name("getInstance()")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (PrimalSharedBignumBigDecimal *)inc __attribute__((swift_name("inc()")));
- (int32_t)intValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("intValue(exactRequired:)")));
- (BOOL)isWholeNumber __attribute__((swift_name("isWholeNumber()")));
- (BOOL)isZero __attribute__((swift_name("isZero()")));
- (int64_t)longValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("longValue(exactRequired:)")));
- (PrimalSharedBignumBigDecimal *)minusOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("minus(other:)")));
- (PrimalSharedBignumBigDecimal *)moveDecimalPointPlaces:(int32_t)places __attribute__((swift_name("moveDecimalPoint(places:)")));
- (PrimalSharedBignumBigDecimal *)moveDecimalPointPlaces_:(int64_t)places __attribute__((swift_name("moveDecimalPoint(places_:)")));
- (PrimalSharedBignumBigDecimal *)multiplyOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("multiply(other:)")));
- (PrimalSharedBignumBigDecimal *)multiplyOther:(PrimalSharedBignumBigDecimal *)other decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("multiply(other:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)negate __attribute__((swift_name("negate()")));
- (int64_t)numberOfDecimalDigits __attribute__((swift_name("numberOfDecimalDigits()")));
- (PrimalSharedBignumBigDecimal *)plusOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("plus(other:)")));
- (PrimalSharedBignumBigDecimal *)powExponent:(int32_t)exponent __attribute__((swift_name("pow(exponent:)")));
- (PrimalSharedBignumBigDecimal *)powExponent_:(int64_t)exponent __attribute__((swift_name("pow(exponent_:)")));
- (PrimalSharedBignumBigDecimal *)remOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("rem(other:)")));
- (PrimalSharedBignumBigDecimal *)remainderOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("remainder(other:)")));
- (PrimalSharedBignumBigDecimal *)removeScale __attribute__((swift_name("removeScale()")));
- (PrimalSharedBignumBigDecimal *)roundSignificandDecimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("roundSignificand(decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)roundToDigitPositionDigitPosition:(int64_t)digitPosition roundingMode:(PrimalSharedBignumRoundingMode *)roundingMode __attribute__((swift_name("roundToDigitPosition(digitPosition:roundingMode:)")));
- (PrimalSharedBignumBigDecimal *)roundToDigitPositionAfterDecimalPointDigitPosition:(int64_t)digitPosition roundingMode:(PrimalSharedBignumRoundingMode *)roundingMode __attribute__((swift_name("roundToDigitPositionAfterDecimalPoint(digitPosition:roundingMode:)")));
- (PrimalSharedBignumBigDecimal *)scaleScale:(int64_t)scale __attribute__((swift_name("scale(scale:)")));
- (void)secureOverwrite __attribute__((swift_name("secureOverwrite()")));
- (int16_t)shortValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("shortValue(exactRequired:)")));
- (int32_t)signum __attribute__((swift_name("signum()")));
- (PrimalSharedBignumBigDecimal *)subtractOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("subtract(other:)")));
- (PrimalSharedBignumBigDecimal *)subtractOther:(PrimalSharedBignumBigDecimal *)other decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("subtract(other:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)timesOther:(PrimalSharedBignumBigDecimal *)other __attribute__((swift_name("times(other:)")));
- (NSString *)times:(int64_t)receiver char:(unichar)char_ __attribute__((swift_name("times(_:char:)")));
- (PrimalSharedBignumBigInteger *)toBigInteger __attribute__((swift_name("toBigInteger()")));
- (NSString *)toPlainString __attribute__((swift_name("toPlainString()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSString *)toStringBase:(int32_t)base __attribute__((swift_name("toString(base:)")));
- (NSString *)toStringExpanded __attribute__((swift_name("toStringExpanded()")));
- (uint8_t)ubyteValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ubyteValue(exactRequired:)")));
- (uint32_t)uintValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("uintValue(exactRequired:)")));
- (uint64_t)ulongValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ulongValue(exactRequired:)")));
- (PrimalSharedBignumBigDecimal *)unaryMinus __attribute__((swift_name("unaryMinus()")));
- (uint16_t)ushortValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ushortValue(exactRequired:)")));
@end

__attribute__((swift_name("KotlinIterator")))
@protocol PrimalSharedKotlinIterator
@required
- (BOOL)hasNext __attribute__((swift_name("hasNext()")));
- (id _Nullable)next __attribute__((swift_name("next()")));
@end

__attribute__((swift_name("KotlinByteIterator")))
@interface PrimalSharedKotlinByteIterator : PrimalSharedBase <PrimalSharedKotlinIterator>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (PrimalSharedByte *)next __attribute__((swift_name("next()")));
- (int8_t)nextByte __attribute__((swift_name("nextByte()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinUuid.Companion")))
@interface PrimalSharedKotlinUuidCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinUuidCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) id<PrimalSharedKotlinComparator> LEXICAL_ORDER __attribute__((swift_name("LEXICAL_ORDER"))) __attribute__((deprecated("Use naturalOrder<Uuid>() instead")));
@property (readonly) PrimalSharedKotlinUuid *NIL __attribute__((swift_name("NIL")));
@property (readonly) int32_t SIZE_BITS __attribute__((swift_name("SIZE_BITS")));
@property (readonly) int32_t SIZE_BYTES __attribute__((swift_name("SIZE_BYTES")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKotlinUuid *)fromByteArrayByteArray:(PrimalSharedKotlinByteArray *)byteArray __attribute__((swift_name("fromByteArray(byteArray:)")));
- (PrimalSharedKotlinUuid *)fromLongsMostSignificantBits:(int64_t)mostSignificantBits leastSignificantBits:(int64_t)leastSignificantBits __attribute__((swift_name("fromLongs(mostSignificantBits:leastSignificantBits:)")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="2.1")
 *   kotlin.ExperimentalUnsignedTypes
*/
- (PrimalSharedKotlinUuid *)fromUByteArrayUbyteArray:(id)ubyteArray __attribute__((swift_name("fromUByteArray(ubyteArray:)")));
- (PrimalSharedKotlinUuid *)fromULongsMostSignificantBits:(uint64_t)mostSignificantBits leastSignificantBits:(uint64_t)leastSignificantBits __attribute__((swift_name("fromULongs(mostSignificantBits:leastSignificantBits:)")));
- (PrimalSharedKotlinUuid *)parseUuidString:(NSString *)uuidString __attribute__((swift_name("parse(uuidString:)")));
- (PrimalSharedKotlinUuid *)parseHexHexString:(NSString *)hexString __attribute__((swift_name("parseHex(hexString:)")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="2.1")
*/
- (PrimalSharedKotlinUuid *)parseHexDashHexDashString:(NSString *)hexDashString __attribute__((swift_name("parseHexDash(hexDashString:)")));
- (PrimalSharedKotlinUuid *)random __attribute__((swift_name("random()")));

/**
 * @note annotations
 *   kotlin.DeprecatedSinceKotlin(warningSince="2.1")
*/
@end

__attribute__((swift_name("KotlinSuspendFunction0")))
@protocol PrimalSharedKotlinSuspendFunction0 <PrimalSharedKotlinFunction>
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)invokeWithCompletionHandler:(void (^)(id _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("invoke(completionHandler:)")));
@end

__attribute__((swift_name("Ktor_httpOutgoingContent")))
@interface PrimalSharedKtor_httpOutgoingContent : PrimalSharedBase
@property (readonly) PrimalSharedLong * _Nullable contentLength __attribute__((swift_name("contentLength")));
@property (readonly) PrimalSharedKtor_httpContentType * _Nullable contentType __attribute__((swift_name("contentType")));
@property (readonly) id<PrimalSharedKtor_httpHeaders> headers __attribute__((swift_name("headers")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode * _Nullable status __attribute__((swift_name("status")));
- (id _Nullable)getPropertyKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("getProperty(key:)")));
- (void)setPropertyKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key value:(id _Nullable)value __attribute__((swift_name("setProperty(key:value:)")));
- (id<PrimalSharedKtor_httpHeaders> _Nullable)trailers __attribute__((swift_name("trailers()")));
@end

__attribute__((swift_name("Ktor_httpOutgoingContent.ProtocolUpgrade")))
@interface PrimalSharedKtor_httpOutgoingContentProtocolUpgrade : PrimalSharedKtor_httpOutgoingContent
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *status __attribute__((swift_name("status")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)upgradeInput:(id<PrimalSharedKtor_ioByteReadChannel>)input output:(id<PrimalSharedKtor_ioByteWriteChannel>)output engineContext:(id<PrimalSharedKotlinCoroutineContext>)engineContext userContext:(id<PrimalSharedKotlinCoroutineContext>)userContext completionHandler:(void (^)(id<PrimalSharedKotlinx_coroutines_coreJob> _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("upgrade(input:output:engineContext:userContext:completionHandler:)")));
@end

__attribute__((swift_name("Ktor_ioByteReadChannel")))
@protocol PrimalSharedKtor_ioByteReadChannel
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)awaitContentMin:(int32_t)min completionHandler:(void (^)(PrimalSharedBoolean * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("awaitContent(min:completionHandler:)")));
- (void)cancelCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("cancel(cause:)")));
@property (readonly) PrimalSharedKotlinThrowable * _Nullable closedCause __attribute__((swift_name("closedCause")));
@property (readonly) BOOL isClosedForRead __attribute__((swift_name("isClosedForRead")));
@property (readonly) id<PrimalSharedKotlinx_io_coreSource> readBuffer __attribute__((swift_name("readBuffer")));
@end

__attribute__((swift_name("Ktor_ioByteWriteChannel")))
@protocol PrimalSharedKtor_ioByteWriteChannel
@required
- (void)cancelCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("cancel(cause:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)flushWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("flush(completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)flushAndCloseWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("flushAndClose(completionHandler:)")));
@property (readonly) PrimalSharedKotlinThrowable * _Nullable closedCause __attribute__((swift_name("closedCause")));
@property (readonly) BOOL isClosedForWrite __attribute__((swift_name("isClosedForWrite")));
@property (readonly) id<PrimalSharedKotlinx_io_coreSink> writeBuffer __attribute__((swift_name("writeBuffer")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinCoroutineContext")))
@protocol PrimalSharedKotlinCoroutineContext
@required
- (id _Nullable)foldInitial:(id _Nullable)initial operation:(id _Nullable (^)(id _Nullable, id<PrimalSharedKotlinCoroutineContextElement>))operation __attribute__((swift_name("fold(initial:operation:)")));
- (id<PrimalSharedKotlinCoroutineContextElement> _Nullable)getKey:(id<PrimalSharedKotlinCoroutineContextKey>)key __attribute__((swift_name("get(key:)")));
- (id<PrimalSharedKotlinCoroutineContext>)minusKeyKey:(id<PrimalSharedKotlinCoroutineContextKey>)key __attribute__((swift_name("minusKey(key:)")));
- (id<PrimalSharedKotlinCoroutineContext>)plusContext:(id<PrimalSharedKotlinCoroutineContext>)context __attribute__((swift_name("plus(context:)")));
@end

__attribute__((swift_name("Ktor_httpOutgoingContent.WriteChannelContent")))
@interface PrimalSharedKtor_httpOutgoingContentWriteChannelContent : PrimalSharedKtor_httpOutgoingContent
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)writeToChannel:(id<PrimalSharedKtor_ioByteWriteChannel>)channel completionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("writeTo(channel:completionHandler:)")));
@end

__attribute__((swift_name("KotlinCoroutineContextElement")))
@protocol PrimalSharedKotlinCoroutineContextElement <PrimalSharedKotlinCoroutineContext>
@required
@property (readonly) id<PrimalSharedKotlinCoroutineContextKey> key __attribute__((swift_name("key")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreJob")))
@protocol PrimalSharedKotlinx_coroutines_coreJob <PrimalSharedKotlinCoroutineContextElement>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (id<PrimalSharedKotlinx_coroutines_coreChildHandle>)attachChildChild:(id<PrimalSharedKotlinx_coroutines_coreChildJob>)child __attribute__((swift_name("attachChild(child:)")));
- (void)cancelCause_:(PrimalSharedKotlinCancellationException * _Nullable)cause __attribute__((swift_name("cancel(cause_:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (PrimalSharedKotlinCancellationException *)getCancellationException __attribute__((swift_name("getCancellationException()")));
- (id<PrimalSharedKotlinx_coroutines_coreDisposableHandle>)invokeOnCompletionHandler:(void (^)(PrimalSharedKotlinThrowable * _Nullable))handler __attribute__((swift_name("invokeOnCompletion(handler:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (id<PrimalSharedKotlinx_coroutines_coreDisposableHandle>)invokeOnCompletionOnCancelling:(BOOL)onCancelling invokeImmediately:(BOOL)invokeImmediately handler:(void (^)(PrimalSharedKotlinThrowable * _Nullable))handler __attribute__((swift_name("invokeOnCompletion(onCancelling:invokeImmediately:handler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)joinWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler __attribute__((swift_name("join(completionHandler:)")));
- (id<PrimalSharedKotlinx_coroutines_coreJob>)plusOther:(id<PrimalSharedKotlinx_coroutines_coreJob>)other __attribute__((swift_name("plus(other:)"))) __attribute__((unavailable("Operator '+' on two Job objects is meaningless. Job is a coroutine context element and `+` is a set-sum operator for coroutine contexts. The job to the right of `+` just replaces the job the left of `+`.")));
- (BOOL)start_ __attribute__((swift_name("start()")));
@property (readonly) id<PrimalSharedKotlinSequence> children __attribute__((swift_name("children")));
@property (readonly) BOOL isActive __attribute__((swift_name("isActive")));
@property (readonly) BOOL isCancelled __attribute__((swift_name("isCancelled")));
@property (readonly) BOOL isCompleted __attribute__((swift_name("isCompleted")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreSelectClause0> onJoin __attribute__((swift_name("onJoin")));

/**
 * @note annotations
 *   kotlinx.coroutines.ExperimentalCoroutinesApi
*/
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreJob> _Nullable parent __attribute__((swift_name("parent")));
@end

__attribute__((swift_name("Ktor_utilsPipeline")))
@interface PrimalSharedKtor_utilsPipeline<TSubject, TContext> : PrimalSharedBase
@property (readonly) id<PrimalSharedKtor_utilsAttributes> attributes __attribute__((swift_name("attributes")));
@property (readonly) BOOL developmentMode __attribute__((swift_name("developmentMode")));
@property (readonly, getter=isEmpty_) BOOL isEmpty __attribute__((swift_name("isEmpty")));
@property (readonly) NSArray<PrimalSharedKtor_utilsPipelinePhase *> *items __attribute__((swift_name("items")));
- (instancetype)initWithPhases:(PrimalSharedKotlinArray<PrimalSharedKtor_utilsPipelinePhase *> *)phases __attribute__((swift_name("init(phases:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithPhase:(PrimalSharedKtor_utilsPipelinePhase *)phase interceptors:(NSArray<id<PrimalSharedKotlinSuspendFunction2>> *)interceptors __attribute__((swift_name("init(phase:interceptors:)"))) __attribute__((objc_designated_initializer));
- (void)addPhasePhase:(PrimalSharedKtor_utilsPipelinePhase *)phase __attribute__((swift_name("addPhase(phase:)")));
- (void)afterIntercepted __attribute__((swift_name("afterIntercepted()")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)executeContext:(TContext)context subject:(TSubject)subject completionHandler:(void (^)(TSubject _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("execute(context:subject:completionHandler:)")));
- (void)insertPhaseAfterReference:(PrimalSharedKtor_utilsPipelinePhase *)reference phase:(PrimalSharedKtor_utilsPipelinePhase *)phase __attribute__((swift_name("insertPhaseAfter(reference:phase:)")));
- (void)insertPhaseBeforeReference:(PrimalSharedKtor_utilsPipelinePhase *)reference phase:(PrimalSharedKtor_utilsPipelinePhase *)phase __attribute__((swift_name("insertPhaseBefore(reference:phase:)")));
- (void)interceptPhase:(PrimalSharedKtor_utilsPipelinePhase *)phase block:(id<PrimalSharedKotlinSuspendFunction2>)block __attribute__((swift_name("intercept(phase:block:)")));
- (NSArray<id<PrimalSharedKotlinSuspendFunction2>> *)interceptorsForPhasePhase:(PrimalSharedKtor_utilsPipelinePhase *)phase __attribute__((swift_name("interceptorsForPhase(phase:)")));
- (void)mergeFrom:(PrimalSharedKtor_utilsPipeline<TSubject, TContext> *)from __attribute__((swift_name("merge(from:)")));
- (void)mergePhasesFrom:(PrimalSharedKtor_utilsPipeline<TSubject, TContext> *)from __attribute__((swift_name("mergePhases(from:)")));
- (void)resetFromFrom:(PrimalSharedKtor_utilsPipeline<TSubject, TContext> *)from __attribute__((swift_name("resetFrom(from:)")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinSuspendFunction2")))
@protocol PrimalSharedKotlinSuspendFunction2 <PrimalSharedKotlinFunction>
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)invokeP1:(id _Nullable)p1 p2:(id _Nullable)p2 completionHandler:(void (^)(id _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("invoke(p1:p2:completionHandler:)")));
@end

__attribute__((swift_name("Ktor_client_coreHttpClientCall")))
@interface PrimalSharedKtor_client_coreHttpClientCall : PrimalSharedBase <PrimalSharedKotlinx_coroutines_coreCoroutineScope>
@property (class, readonly, getter=companion) PrimalSharedKtor_client_coreHttpClientCallCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) BOOL allowDoubleReceive __attribute__((swift_name("allowDoubleReceive")));
@property (readonly) id<PrimalSharedKtor_utilsAttributes> attributes __attribute__((swift_name("attributes")));
@property (readonly) PrimalSharedKtor_client_coreHttpClient *client __attribute__((swift_name("client")));
@property (readonly) id<PrimalSharedKotlinCoroutineContext> coroutineContext __attribute__((swift_name("coroutineContext")));
@property id<PrimalSharedKtor_client_coreHttpRequest> request __attribute__((swift_name("request")));
@property PrimalSharedKtor_client_coreHttpResponse *response __attribute__((swift_name("response")));
- (instancetype)initWithClient:(PrimalSharedKtor_client_coreHttpClient *)client __attribute__((swift_name("init(client:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithClient:(PrimalSharedKtor_client_coreHttpClient *)client requestData:(PrimalSharedKtor_client_coreHttpRequestData *)requestData responseData:(PrimalSharedKtor_client_coreHttpResponseData *)responseData __attribute__((swift_name("init(client:requestData:responseData:)"))) __attribute__((objc_designated_initializer));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)bodyInfo:(PrimalSharedKtor_utilsTypeInfo *)info completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("body(info:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)bodyNullableInfo:(PrimalSharedKtor_utilsTypeInfo *)info completionHandler:(void (^)(id _Nullable_result, NSError * _Nullable))completionHandler __attribute__((swift_name("bodyNullable(info:completionHandler:)")));

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (void)getResponseContentWithCompletionHandler:(void (^)(id<PrimalSharedKtor_ioByteReadChannel> _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("getResponseContent(completionHandler:)")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsTypeInfo")))
@interface PrimalSharedKtor_utilsTypeInfo : PrimalSharedBase
@property (readonly) id<PrimalSharedKotlinKType> _Nullable kotlinType __attribute__((swift_name("kotlinType")));
@property (readonly) id<PrimalSharedKotlinKClass> type __attribute__((swift_name("type")));
- (instancetype)initWithType:(id<PrimalSharedKotlinKClass>)type kotlinType:(id<PrimalSharedKotlinKType> _Nullable)kotlinType __attribute__((swift_name("init(type:kotlinType:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithType:(id<PrimalSharedKotlinKClass>)type reifiedType:(id<PrimalSharedKotlinKType>)reifiedType kotlinType:(id<PrimalSharedKotlinKType> _Nullable)kotlinType __attribute__((swift_name("init(type:reifiedType:kotlinType:)"))) __attribute__((objc_designated_initializer)) __attribute__((deprecated("Use constructor without reifiedType parameter.")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Ktor_client_coreHttpClientEngine")))
@protocol PrimalSharedKtor_client_coreHttpClientEngine <PrimalSharedKotlinx_coroutines_coreCoroutineScope, PrimalSharedKtor_ioCloseable>
@required

/**
 * @note This method converts instances of CancellationException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (void)executeData:(PrimalSharedKtor_client_coreHttpRequestData *)data completionHandler:(void (^)(PrimalSharedKtor_client_coreHttpResponseData * _Nullable, NSError * _Nullable))completionHandler __attribute__((swift_name("execute(data:completionHandler:)")));
- (void)installClient:(PrimalSharedKtor_client_coreHttpClient *)client __attribute__((swift_name("install(client:)")));
@property (readonly) PrimalSharedKtor_client_coreHttpClientEngineConfig *config __attribute__((swift_name("config")));
@property (readonly) PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher *dispatcher __attribute__((swift_name("dispatcher")));
@property (readonly) NSSet<id<PrimalSharedKtor_client_coreHttpClientEngineCapability>> *supportedCapabilities __attribute__((swift_name("supportedCapabilities")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpRequestData")))
@interface PrimalSharedKtor_client_coreHttpRequestData : PrimalSharedBase
@property (readonly) id<PrimalSharedKtor_utilsAttributes> attributes __attribute__((swift_name("attributes")));
@property (readonly) PrimalSharedKtor_httpOutgoingContent *body __attribute__((swift_name("body")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreJob> executionContext __attribute__((swift_name("executionContext")));
@property (readonly) id<PrimalSharedKtor_httpHeaders> headers __attribute__((swift_name("headers")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *method __attribute__((swift_name("method")));
@property (readonly) PrimalSharedKtor_httpUrl *url __attribute__((swift_name("url")));
- (instancetype)initWithUrl:(PrimalSharedKtor_httpUrl *)url method:(PrimalSharedKtor_httpHttpMethod *)method headers:(id<PrimalSharedKtor_httpHeaders>)headers body:(PrimalSharedKtor_httpOutgoingContent *)body executionContext:(id<PrimalSharedKotlinx_coroutines_coreJob>)executionContext attributes:(id<PrimalSharedKtor_utilsAttributes>)attributes __attribute__((swift_name("init(url:method:headers:body:executionContext:attributes:)"))) __attribute__((objc_designated_initializer));
- (id _Nullable)getCapabilityOrNullKey:(id<PrimalSharedKtor_client_coreHttpClientEngineCapability>)key __attribute__((swift_name("getCapabilityOrNull(key:)")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Paging_commonPagingData")))
@interface PrimalSharedPaging_commonPagingData<T> : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedPaging_commonPagingDataCompanion *companion __attribute__((swift_name("companion")));
@end

__attribute__((swift_name("Ktor_httpOutgoingContent.ByteArrayContent")))
@interface PrimalSharedKtor_httpOutgoingContentByteArrayContent : PrimalSharedKtor_httpOutgoingContent
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (PrimalSharedKotlinByteArray *)bytes __attribute__((swift_name("bytes()")));
@end

__attribute__((swift_name("Ktor_httpOutgoingContent.ContentWrapper")))
@interface PrimalSharedKtor_httpOutgoingContentContentWrapper : PrimalSharedKtor_httpOutgoingContent
@property (readonly) PrimalSharedLong * _Nullable contentLength __attribute__((swift_name("contentLength")));
@property (readonly) PrimalSharedKtor_httpContentType * _Nullable contentType __attribute__((swift_name("contentType")));
@property (readonly) id<PrimalSharedKtor_httpHeaders> headers __attribute__((swift_name("headers")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode * _Nullable status __attribute__((swift_name("status")));
- (instancetype)initWithDelegate:(PrimalSharedKtor_httpOutgoingContent *)delegate __attribute__((swift_name("init(delegate:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_httpOutgoingContentContentWrapper *)doCopyDelegate:(PrimalSharedKtor_httpOutgoingContent *)delegate __attribute__((swift_name("doCopy(delegate:)")));
- (PrimalSharedKtor_httpOutgoingContent *)delegate __attribute__((swift_name("delegate()")));
- (id _Nullable)getPropertyKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("getProperty(key:)")));
- (void)setPropertyKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key value:(id _Nullable)value __attribute__((swift_name("setProperty(key:value:)")));
@end

__attribute__((swift_name("Ktor_httpOutgoingContent.NoContent")))
@interface PrimalSharedKtor_httpOutgoingContentNoContent : PrimalSharedKtor_httpOutgoingContent
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
@end

__attribute__((swift_name("Ktor_httpOutgoingContent.ReadChannelContent")))
@interface PrimalSharedKtor_httpOutgoingContentReadChannelContent : PrimalSharedKtor_httpOutgoingContent
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (id<PrimalSharedKtor_ioByteReadChannel>)readFrom __attribute__((swift_name("readFrom()")));
- (id<PrimalSharedKtor_ioByteReadChannel>)readFromRange:(PrimalSharedKotlinLongRange *)range __attribute__((swift_name("readFrom(range:)")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause")))
@protocol PrimalSharedKotlinx_coroutines_coreSelectClause
@required
@property (readonly) id clauseObject __attribute__((swift_name("clauseObject")));
@property (readonly) PrimalSharedKotlinUnit *(^(^ _Nullable onCancellationConstructor)(id<PrimalSharedKotlinx_coroutines_coreSelectInstance>, id _Nullable, id _Nullable))(PrimalSharedKotlinThrowable *, id _Nullable, id<PrimalSharedKotlinCoroutineContext>) __attribute__((swift_name("onCancellationConstructor")));
@property (readonly) id _Nullable (^processResFunc)(id, id _Nullable, id _Nullable) __attribute__((swift_name("processResFunc")));
@property (readonly) void (^regFunc)(id, id<PrimalSharedKotlinx_coroutines_coreSelectInstance>, id _Nullable) __attribute__((swift_name("regFunc")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause1")))
@protocol PrimalSharedKotlinx_coroutines_coreSelectClause1 <PrimalSharedKotlinx_coroutines_coreSelectClause>
@required
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause2")))
@protocol PrimalSharedKotlinx_coroutines_coreSelectClause2 <PrimalSharedKotlinx_coroutines_coreSelectClause>
@required
@end

__attribute__((swift_name("Kotlinx_serialization_coreSerialKind")))
@interface PrimalSharedKotlinx_serialization_coreSerialKind : PrimalSharedBase
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
__attribute__((swift_name("Kotlinx_serialization_corePolymorphicKind")))
@interface PrimalSharedKotlinx_serialization_corePolymorphicKind : PrimalSharedKotlinx_serialization_coreSerialKind
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePolymorphicKind.OPEN")))
@interface PrimalSharedKotlinx_serialization_corePolymorphicKindOPEN : PrimalSharedKotlinx_serialization_corePolymorphicKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePolymorphicKindOPEN *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)oPEN __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePolymorphicKind.SEALED")))
@interface PrimalSharedKotlinx_serialization_corePolymorphicKindSEALED : PrimalSharedKotlinx_serialization_corePolymorphicKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePolymorphicKindSEALED *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sEALED __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKind : PrimalSharedKotlinx_serialization_coreSerialKind
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.BOOLEAN")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindBOOLEAN : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindBOOLEAN *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)bOOLEAN __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.BYTE")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindBYTE : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindBYTE *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)bYTE __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.CHAR")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindCHAR : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindCHAR *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)cHAR __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.DOUBLE")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindDOUBLE : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindDOUBLE *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)dOUBLE __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.FLOAT")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindFLOAT : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindFLOAT *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)fLOAT __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.INT")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindINT : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindINT *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)iNT __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.LONG")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindLONG : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindLONG *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)lONG __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.SHORT")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindSHORT : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindSHORT *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sHORT __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_corePrimitiveKind.STRING")))
@interface PrimalSharedKotlinx_serialization_corePrimitiveKindSTRING : PrimalSharedKotlinx_serialization_corePrimitiveKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_corePrimitiveKindSTRING *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)sTRING __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_coreSerialKind.CONTEXTUAL")))
@interface PrimalSharedKotlinx_serialization_coreSerialKindCONTEXTUAL : PrimalSharedKotlinx_serialization_coreSerialKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_coreSerialKindCONTEXTUAL *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)cONTEXTUAL __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_coreSerialKind.ENUM")))
@interface PrimalSharedKotlinx_serialization_coreSerialKindENUM : PrimalSharedKotlinx_serialization_coreSerialKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_coreSerialKindENUM *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)eNUM __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreStructureKind")))
@interface PrimalSharedKotlinx_serialization_coreStructureKind : PrimalSharedKotlinx_serialization_coreSerialKind
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_coreStructureKind.CLASS")))
@interface PrimalSharedKotlinx_serialization_coreStructureKindCLASS : PrimalSharedKotlinx_serialization_coreStructureKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_coreStructureKindCLASS *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)cLASS __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_coreStructureKind.LIST")))
@interface PrimalSharedKotlinx_serialization_coreStructureKindLIST : PrimalSharedKotlinx_serialization_coreStructureKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_coreStructureKindLIST *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)lIST __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_coreStructureKind.MAP")))
@interface PrimalSharedKotlinx_serialization_coreStructureKindMAP : PrimalSharedKotlinx_serialization_coreStructureKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_coreStructureKindMAP *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)mAP __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_coreStructureKind.OBJECT")))
@interface PrimalSharedKotlinx_serialization_coreStructureKindOBJECT : PrimalSharedKotlinx_serialization_coreStructureKind
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_coreStructureKindOBJECT *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)oBJECT __attribute__((swift_name("init()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable(with=NormalClass(value=kotlinx/serialization/json/JsonPrimitiveSerializer))
*/
__attribute__((swift_name("Kotlinx_serialization_jsonJsonPrimitive")))
@interface PrimalSharedKotlinx_serialization_jsonJsonPrimitive : PrimalSharedKotlinx_serialization_jsonJsonElement
@property (class, readonly, getter=companion) PrimalSharedKotlinx_serialization_jsonJsonPrimitiveCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) BOOL isString __attribute__((swift_name("isString")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable(with=NormalClass(value=kotlinx/serialization/json/JsonNullSerializer))
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_jsonJsonNull")))
@interface PrimalSharedKotlinx_serialization_jsonJsonNull : PrimalSharedKotlinx_serialization_jsonJsonPrimitive
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_jsonJsonNull *shared __attribute__((swift_name("shared")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) BOOL isString __attribute__((swift_name("isString")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)jsonNull __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializerTypeParamsSerializers:(PrimalSharedKotlinArray<id<PrimalSharedKotlinx_serialization_coreKSerializer>> *)typeParamsSerializers __attribute__((swift_name("serializer(typeParamsSerializers:)")));
@end

__attribute__((swift_name("Paging_commonLoadState")))
@interface PrimalSharedPaging_commonLoadState : PrimalSharedBase
@property (readonly) BOOL endOfPaginationReached __attribute__((swift_name("endOfPaginationReached")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Paging_commonLoadState.Error")))
@interface PrimalSharedPaging_commonLoadStateError : PrimalSharedPaging_commonLoadState
@property (readonly) PrimalSharedKotlinThrowable *error __attribute__((swift_name("error")));
- (instancetype)initWithError:(PrimalSharedKotlinThrowable *)error __attribute__((swift_name("init(error:)"))) __attribute__((objc_designated_initializer));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Paging_commonLoadState.Loading")))
@interface PrimalSharedPaging_commonLoadStateLoading : PrimalSharedPaging_commonLoadState
@property (class, readonly, getter=shared) PrimalSharedPaging_commonLoadStateLoading *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)loading __attribute__((swift_name("init()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Paging_commonLoadState.NotLoading")))
@interface PrimalSharedPaging_commonLoadStateNotLoading : PrimalSharedPaging_commonLoadState
- (instancetype)initWithEndOfPaginationReached:(BOOL)endOfPaginationReached __attribute__((swift_name("init(endOfPaginationReached:)"))) __attribute__((objc_designated_initializer));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreEncoder")))
@protocol PrimalSharedKotlinx_serialization_coreEncoder
@required
- (id<PrimalSharedKotlinx_serialization_coreCompositeEncoder>)beginCollectionDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor collectionSize:(int32_t)collectionSize __attribute__((swift_name("beginCollection(descriptor:collectionSize:)")));
- (id<PrimalSharedKotlinx_serialization_coreCompositeEncoder>)beginStructureDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("beginStructure(descriptor:)")));
- (void)encodeBooleanValue:(BOOL)value __attribute__((swift_name("encodeBoolean(value:)")));
- (void)encodeByteValue:(int8_t)value __attribute__((swift_name("encodeByte(value:)")));
- (void)encodeCharValue:(unichar)value __attribute__((swift_name("encodeChar(value:)")));
- (void)encodeDoubleValue:(double)value __attribute__((swift_name("encodeDouble(value:)")));
- (void)encodeEnumEnumDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)enumDescriptor index:(int32_t)index __attribute__((swift_name("encodeEnum(enumDescriptor:index:)")));
- (void)encodeFloatValue:(float)value __attribute__((swift_name("encodeFloat(value:)")));
- (id<PrimalSharedKotlinx_serialization_coreEncoder>)encodeInlineDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("encodeInline(descriptor:)")));
- (void)encodeIntValue:(int32_t)value __attribute__((swift_name("encodeInt(value:)")));
- (void)encodeLongValue:(int64_t)value __attribute__((swift_name("encodeLong(value:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNotNullMark __attribute__((swift_name("encodeNotNullMark()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNull __attribute__((swift_name("encodeNull()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNullableSerializableValueSerializer:(id<PrimalSharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeNullableSerializableValue(serializer:value:)")));
- (void)encodeSerializableValueSerializer:(id<PrimalSharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeSerializableValue(serializer:value:)")));
- (void)encodeShortValue:(int16_t)value __attribute__((swift_name("encodeShort(value:)")));
- (void)encodeStringValue:(NSString *)value __attribute__((swift_name("encodeString(value:)")));
@property (readonly) PrimalSharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreSerialDescriptor")))
@protocol PrimalSharedKotlinx_serialization_coreSerialDescriptor
@required
- (NSArray<id<PrimalSharedKotlinAnnotation>> *)getElementAnnotationsIndex:(int32_t)index __attribute__((swift_name("getElementAnnotations(index:)")));
- (id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)getElementDescriptorIndex:(int32_t)index __attribute__((swift_name("getElementDescriptor(index:)")));
- (int32_t)getElementIndexName:(NSString *)name __attribute__((swift_name("getElementIndex(name:)")));
- (NSString *)getElementNameIndex:(int32_t)index __attribute__((swift_name("getElementName(index:)")));
- (BOOL)isElementOptionalIndex:(int32_t)index __attribute__((swift_name("isElementOptional(index:)")));
@property (readonly) NSArray<id<PrimalSharedKotlinAnnotation>> *annotations __attribute__((swift_name("annotations")));
@property (readonly) int32_t elementsCount __attribute__((swift_name("elementsCount")));
@property (readonly) BOOL isInline __attribute__((swift_name("isInline")));
@property (readonly) BOOL isNullable __attribute__((swift_name("isNullable")));
@property (readonly) PrimalSharedKotlinx_serialization_coreSerialKind *kind __attribute__((swift_name("kind")));
@property (readonly) NSString *serialName __attribute__((swift_name("serialName")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreDecoder")))
@protocol PrimalSharedKotlinx_serialization_coreDecoder
@required
- (id<PrimalSharedKotlinx_serialization_coreCompositeDecoder>)beginStructureDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("beginStructure(descriptor:)")));
- (BOOL)decodeBoolean __attribute__((swift_name("decodeBoolean()")));
- (int8_t)decodeByte __attribute__((swift_name("decodeByte()")));
- (unichar)decodeChar __attribute__((swift_name("decodeChar()")));
- (double)decodeDouble __attribute__((swift_name("decodeDouble()")));
- (int32_t)decodeEnumEnumDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)enumDescriptor __attribute__((swift_name("decodeEnum(enumDescriptor:)")));
- (float)decodeFloat __attribute__((swift_name("decodeFloat()")));
- (id<PrimalSharedKotlinx_serialization_coreDecoder>)decodeInlineDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("decodeInline(descriptor:)")));
- (int32_t)decodeInt __attribute__((swift_name("decodeInt()")));
- (int64_t)decodeLong __attribute__((swift_name("decodeLong()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (BOOL)decodeNotNullMark __attribute__((swift_name("decodeNotNullMark()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (PrimalSharedKotlinNothing * _Nullable)decodeNull __attribute__((swift_name("decodeNull()")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id _Nullable)decodeNullableSerializableValueDeserializer:(id<PrimalSharedKotlinx_serialization_coreDeserializationStrategy>)deserializer __attribute__((swift_name("decodeNullableSerializableValue(deserializer:)")));
- (id _Nullable)decodeSerializableValueDeserializer:(id<PrimalSharedKotlinx_serialization_coreDeserializationStrategy>)deserializer __attribute__((swift_name("decodeSerializableValue(deserializer:)")));
- (int16_t)decodeShort __attribute__((swift_name("decodeShort()")));
- (NSString *)decodeString __attribute__((swift_name("decodeString()")));
@property (readonly) PrimalSharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((swift_name("OkioByteString")))
@interface PrimalSharedOkioByteString : PrimalSharedBase <PrimalSharedKotlinComparable>
@property (class, readonly, getter=companion) PrimalSharedOkioByteStringCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t size __attribute__((swift_name("size")));
- (NSString *)base64 __attribute__((swift_name("base64()")));
- (NSString *)base64Url __attribute__((swift_name("base64Url()")));
- (int32_t)compareToOther:(PrimalSharedOkioByteString *)other __attribute__((swift_name("compareTo(other:)")));
- (void)doCopyIntoOffset:(int32_t)offset target:(PrimalSharedKotlinByteArray *)target targetOffset:(int32_t)targetOffset byteCount:(int32_t)byteCount __attribute__((swift_name("doCopyInto(offset:target:targetOffset:byteCount:)")));
- (BOOL)endsWithSuffix:(PrimalSharedKotlinByteArray *)suffix __attribute__((swift_name("endsWith(suffix:)")));
- (BOOL)endsWithSuffix_:(PrimalSharedOkioByteString *)suffix __attribute__((swift_name("endsWith(suffix_:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (int8_t)getIndex:(int32_t)index __attribute__((swift_name("get(index:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)hex __attribute__((swift_name("hex()")));
- (PrimalSharedOkioByteString *)hmacSha1Key:(PrimalSharedOkioByteString *)key __attribute__((swift_name("hmacSha1(key:)")));
- (PrimalSharedOkioByteString *)hmacSha256Key:(PrimalSharedOkioByteString *)key __attribute__((swift_name("hmacSha256(key:)")));
- (PrimalSharedOkioByteString *)hmacSha512Key:(PrimalSharedOkioByteString *)key __attribute__((swift_name("hmacSha512(key:)")));
- (int32_t)indexOfOther:(PrimalSharedKotlinByteArray *)other fromIndex:(int32_t)fromIndex __attribute__((swift_name("indexOf(other:fromIndex:)")));
- (int32_t)indexOfOther:(PrimalSharedOkioByteString *)other fromIndex_:(int32_t)fromIndex __attribute__((swift_name("indexOf(other:fromIndex_:)")));
- (int32_t)lastIndexOfOther:(PrimalSharedKotlinByteArray *)other fromIndex:(int32_t)fromIndex __attribute__((swift_name("lastIndexOf(other:fromIndex:)")));
- (int32_t)lastIndexOfOther:(PrimalSharedOkioByteString *)other fromIndex_:(int32_t)fromIndex __attribute__((swift_name("lastIndexOf(other:fromIndex_:)")));
- (PrimalSharedOkioByteString *)md5 __attribute__((swift_name("md5()")));
- (BOOL)rangeEqualsOffset:(int32_t)offset other:(PrimalSharedKotlinByteArray *)other otherOffset:(int32_t)otherOffset byteCount:(int32_t)byteCount __attribute__((swift_name("rangeEquals(offset:other:otherOffset:byteCount:)")));
- (BOOL)rangeEqualsOffset:(int32_t)offset other:(PrimalSharedOkioByteString *)other otherOffset:(int32_t)otherOffset byteCount_:(int32_t)byteCount __attribute__((swift_name("rangeEquals(offset:other:otherOffset:byteCount_:)")));
- (PrimalSharedOkioByteString *)sha1 __attribute__((swift_name("sha1()")));
- (PrimalSharedOkioByteString *)sha256 __attribute__((swift_name("sha256()")));
- (PrimalSharedOkioByteString *)sha512 __attribute__((swift_name("sha512()")));
- (BOOL)startsWithPrefix:(PrimalSharedKotlinByteArray *)prefix __attribute__((swift_name("startsWith(prefix:)")));
- (BOOL)startsWithPrefix_:(PrimalSharedOkioByteString *)prefix __attribute__((swift_name("startsWith(prefix_:)")));
- (PrimalSharedOkioByteString *)substringBeginIndex:(int32_t)beginIndex endIndex:(int32_t)endIndex __attribute__((swift_name("substring(beginIndex:endIndex:)")));
- (PrimalSharedOkioByteString *)toAsciiLowercase __attribute__((swift_name("toAsciiLowercase()")));
- (PrimalSharedOkioByteString *)toAsciiUppercase __attribute__((swift_name("toAsciiUppercase()")));
- (PrimalSharedKotlinByteArray *)toByteArray __attribute__((swift_name("toByteArray()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSString *)utf8 __attribute__((swift_name("utf8()")));
@end

__attribute__((swift_name("OkioSink")))
@protocol PrimalSharedOkioSink <PrimalSharedOkioCloseable>
@required

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)flushAndReturnError:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("flush()")));
- (PrimalSharedOkioTimeout *)timeout __attribute__((swift_name("timeout()")));

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)writeSource:(PrimalSharedOkioBuffer *)source byteCount:(int64_t)byteCount error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("write(source:byteCount:)")));
@end

__attribute__((swift_name("OkioBufferedSink")))
@protocol PrimalSharedOkioBufferedSink <PrimalSharedOkioSink>
@required
- (id<PrimalSharedOkioBufferedSink>)emit __attribute__((swift_name("emit()")));
- (id<PrimalSharedOkioBufferedSink>)emitCompleteSegments __attribute__((swift_name("emitCompleteSegments()")));
- (id<PrimalSharedOkioBufferedSink>)writeSource:(PrimalSharedKotlinByteArray *)source __attribute__((swift_name("write(source:)")));
- (id<PrimalSharedOkioBufferedSink>)writeByteString:(PrimalSharedOkioByteString *)byteString __attribute__((swift_name("write(byteString:)")));
- (id<PrimalSharedOkioBufferedSink>)writeSource:(id<PrimalSharedOkioSource>)source byteCount:(int64_t)byteCount __attribute__((swift_name("write(source:byteCount_:)")));
- (id<PrimalSharedOkioBufferedSink>)writeSource:(PrimalSharedKotlinByteArray *)source offset:(int32_t)offset byteCount:(int32_t)byteCount __attribute__((swift_name("write(source:offset:byteCount:)")));
- (id<PrimalSharedOkioBufferedSink>)writeByteString:(PrimalSharedOkioByteString *)byteString offset:(int32_t)offset byteCount:(int32_t)byteCount __attribute__((swift_name("write(byteString:offset:byteCount:)")));
- (int64_t)writeAllSource:(id<PrimalSharedOkioSource>)source __attribute__((swift_name("writeAll(source:)")));
- (id<PrimalSharedOkioBufferedSink>)writeByteB:(int32_t)b __attribute__((swift_name("writeByte(b:)")));
- (id<PrimalSharedOkioBufferedSink>)writeDecimalLongV:(int64_t)v __attribute__((swift_name("writeDecimalLong(v:)")));
- (id<PrimalSharedOkioBufferedSink>)writeHexadecimalUnsignedLongV:(int64_t)v __attribute__((swift_name("writeHexadecimalUnsignedLong(v:)")));
- (id<PrimalSharedOkioBufferedSink>)writeIntI:(int32_t)i __attribute__((swift_name("writeInt(i:)")));
- (id<PrimalSharedOkioBufferedSink>)writeIntLeI:(int32_t)i __attribute__((swift_name("writeIntLe(i:)")));
- (id<PrimalSharedOkioBufferedSink>)writeLongV:(int64_t)v __attribute__((swift_name("writeLong(v:)")));
- (id<PrimalSharedOkioBufferedSink>)writeLongLeV:(int64_t)v __attribute__((swift_name("writeLongLe(v:)")));
- (id<PrimalSharedOkioBufferedSink>)writeShortS:(int32_t)s __attribute__((swift_name("writeShort(s:)")));
- (id<PrimalSharedOkioBufferedSink>)writeShortLeS:(int32_t)s __attribute__((swift_name("writeShortLe(s:)")));
- (id<PrimalSharedOkioBufferedSink>)writeUtf8String:(NSString *)string __attribute__((swift_name("writeUtf8(string:)")));
- (id<PrimalSharedOkioBufferedSink>)writeUtf8String:(NSString *)string beginIndex:(int32_t)beginIndex endIndex:(int32_t)endIndex __attribute__((swift_name("writeUtf8(string:beginIndex:endIndex:)")));
- (id<PrimalSharedOkioBufferedSink>)writeUtf8CodePointCodePoint:(int32_t)codePoint __attribute__((swift_name("writeUtf8CodePoint(codePoint:)")));
@property (readonly) PrimalSharedOkioBuffer *buffer __attribute__((swift_name("buffer")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("OkioBuffer")))
@interface PrimalSharedOkioBuffer : PrimalSharedBase <PrimalSharedOkioBufferedSource, PrimalSharedOkioBufferedSink>
@property (readonly) PrimalSharedOkioBuffer *buffer __attribute__((swift_name("buffer")));
@property (readonly) int64_t size __attribute__((swift_name("size")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (void)clear __attribute__((swift_name("clear()")));

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)closeAndReturnError:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("close()")));
- (int64_t)completeSegmentByteCount __attribute__((swift_name("completeSegmentByteCount()")));
- (PrimalSharedOkioBuffer *)doCopy __attribute__((swift_name("doCopy()")));
- (PrimalSharedOkioBuffer *)doCopyToOut:(PrimalSharedOkioBuffer *)out offset:(int64_t)offset __attribute__((swift_name("doCopyTo(out:offset:)")));
- (PrimalSharedOkioBuffer *)doCopyToOut:(PrimalSharedOkioBuffer *)out offset:(int64_t)offset byteCount:(int64_t)byteCount __attribute__((swift_name("doCopyTo(out:offset:byteCount:)")));
- (PrimalSharedOkioBuffer *)emit __attribute__((swift_name("emit()")));
- (PrimalSharedOkioBuffer *)emitCompleteSegments __attribute__((swift_name("emitCompleteSegments()")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (BOOL)exhausted __attribute__((swift_name("exhausted()")));

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)flushAndReturnError:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("flush()")));
- (int8_t)getPos:(int64_t)pos __attribute__((swift_name("get(pos:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (PrimalSharedOkioByteString *)hmacSha1Key:(PrimalSharedOkioByteString *)key __attribute__((swift_name("hmacSha1(key:)")));
- (PrimalSharedOkioByteString *)hmacSha256Key:(PrimalSharedOkioByteString *)key __attribute__((swift_name("hmacSha256(key:)")));
- (PrimalSharedOkioByteString *)hmacSha512Key:(PrimalSharedOkioByteString *)key __attribute__((swift_name("hmacSha512(key:)")));
- (int64_t)indexOfB:(int8_t)b __attribute__((swift_name("indexOf(b:)")));
- (int64_t)indexOfBytes:(PrimalSharedOkioByteString *)bytes __attribute__((swift_name("indexOf(bytes:)")));
- (int64_t)indexOfB:(int8_t)b fromIndex:(int64_t)fromIndex __attribute__((swift_name("indexOf(b:fromIndex:)")));
- (int64_t)indexOfBytes:(PrimalSharedOkioByteString *)bytes fromIndex:(int64_t)fromIndex __attribute__((swift_name("indexOf(bytes:fromIndex:)")));
- (int64_t)indexOfB:(int8_t)b fromIndex:(int64_t)fromIndex toIndex:(int64_t)toIndex __attribute__((swift_name("indexOf(b:fromIndex:toIndex:)")));
- (int64_t)indexOfBytes:(PrimalSharedOkioByteString *)bytes fromIndex:(int64_t)fromIndex toIndex:(int64_t)toIndex __attribute__((swift_name("indexOf(bytes:fromIndex:toIndex:)")));
- (int64_t)indexOfElementTargetBytes:(PrimalSharedOkioByteString *)targetBytes __attribute__((swift_name("indexOfElement(targetBytes:)")));
- (int64_t)indexOfElementTargetBytes:(PrimalSharedOkioByteString *)targetBytes fromIndex:(int64_t)fromIndex __attribute__((swift_name("indexOfElement(targetBytes:fromIndex:)")));
- (PrimalSharedOkioByteString *)md5 __attribute__((swift_name("md5()")));
- (id<PrimalSharedOkioBufferedSource>)peek __attribute__((swift_name("peek()")));
- (BOOL)rangeEqualsOffset:(int64_t)offset bytes:(PrimalSharedOkioByteString *)bytes __attribute__((swift_name("rangeEquals(offset:bytes:)")));
- (BOOL)rangeEqualsOffset:(int64_t)offset bytes:(PrimalSharedOkioByteString *)bytes bytesOffset:(int32_t)bytesOffset byteCount:(int32_t)byteCount __attribute__((swift_name("rangeEquals(offset:bytes:bytesOffset:byteCount:)")));
- (int32_t)readSink:(PrimalSharedKotlinByteArray *)sink __attribute__((swift_name("read(sink:)")));

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (int64_t)readSink:(PrimalSharedOkioBuffer *)sink byteCount:(int64_t)byteCount error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("read(sink:byteCount:)"))) __attribute__((swift_error(nonnull_error)));
- (int32_t)readSink:(PrimalSharedKotlinByteArray *)sink offset:(int32_t)offset byteCount:(int32_t)byteCount __attribute__((swift_name("read(sink:offset:byteCount:)")));
- (int64_t)readAllSink:(id<PrimalSharedOkioSink>)sink __attribute__((swift_name("readAll(sink:)")));
- (PrimalSharedOkioBufferUnsafeCursor *)readAndWriteUnsafeUnsafeCursor:(PrimalSharedOkioBufferUnsafeCursor *)unsafeCursor __attribute__((swift_name("readAndWriteUnsafe(unsafeCursor:)")));
- (int8_t)readByte __attribute__((swift_name("readByte()")));
- (PrimalSharedKotlinByteArray *)readByteArray __attribute__((swift_name("readByteArray()")));
- (PrimalSharedKotlinByteArray *)readByteArrayByteCount:(int64_t)byteCount __attribute__((swift_name("readByteArray(byteCount:)")));
- (PrimalSharedOkioByteString *)readByteString __attribute__((swift_name("readByteString()")));
- (PrimalSharedOkioByteString *)readByteStringByteCount:(int64_t)byteCount __attribute__((swift_name("readByteString(byteCount:)")));
- (int64_t)readDecimalLong __attribute__((swift_name("readDecimalLong()")));
- (void)readFullySink:(PrimalSharedKotlinByteArray *)sink __attribute__((swift_name("readFully(sink:)")));
- (void)readFullySink:(PrimalSharedOkioBuffer *)sink byteCount:(int64_t)byteCount __attribute__((swift_name("readFully(sink:byteCount:)")));
- (int64_t)readHexadecimalUnsignedLong __attribute__((swift_name("readHexadecimalUnsignedLong()")));
- (int32_t)readInt __attribute__((swift_name("readInt()")));
- (int32_t)readIntLe __attribute__((swift_name("readIntLe()")));
- (int64_t)readLong __attribute__((swift_name("readLong()")));
- (int64_t)readLongLe __attribute__((swift_name("readLongLe()")));
- (int16_t)readShort __attribute__((swift_name("readShort()")));
- (int16_t)readShortLe __attribute__((swift_name("readShortLe()")));
- (PrimalSharedOkioBufferUnsafeCursor *)readUnsafeUnsafeCursor:(PrimalSharedOkioBufferUnsafeCursor *)unsafeCursor __attribute__((swift_name("readUnsafe(unsafeCursor:)")));
- (NSString *)readUtf8 __attribute__((swift_name("readUtf8()")));
- (NSString *)readUtf8ByteCount:(int64_t)byteCount __attribute__((swift_name("readUtf8(byteCount:)")));
- (int32_t)readUtf8CodePoint __attribute__((swift_name("readUtf8CodePoint()")));
- (NSString * _Nullable)readUtf8Line __attribute__((swift_name("readUtf8Line()")));
- (NSString *)readUtf8LineStrict __attribute__((swift_name("readUtf8LineStrict()")));
- (NSString *)readUtf8LineStrictLimit:(int64_t)limit __attribute__((swift_name("readUtf8LineStrict(limit:)")));
- (BOOL)requestByteCount:(int64_t)byteCount __attribute__((swift_name("request(byteCount:)")));
- (void)requireByteCount:(int64_t)byteCount __attribute__((swift_name("require(byteCount:)")));
- (int32_t)selectOptions:(NSArray<PrimalSharedOkioByteString *> *)options __attribute__((swift_name("select(options:)")));
- (id _Nullable)selectOptions_:(NSArray<id> *)options __attribute__((swift_name("select(options_:)")));
- (PrimalSharedOkioByteString *)sha1 __attribute__((swift_name("sha1()")));
- (PrimalSharedOkioByteString *)sha256 __attribute__((swift_name("sha256()")));
- (PrimalSharedOkioByteString *)sha512 __attribute__((swift_name("sha512()")));
- (void)skipByteCount:(int64_t)byteCount __attribute__((swift_name("skip(byteCount:)")));
- (PrimalSharedOkioByteString *)snapshot __attribute__((swift_name("snapshot()")));
- (PrimalSharedOkioByteString *)snapshotByteCount:(int32_t)byteCount __attribute__((swift_name("snapshot(byteCount:)")));
- (PrimalSharedOkioTimeout *)timeout __attribute__((swift_name("timeout()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (PrimalSharedOkioBuffer *)writeSource:(PrimalSharedKotlinByteArray *)source __attribute__((swift_name("write(source:)")));
- (PrimalSharedOkioBuffer *)writeByteString:(PrimalSharedOkioByteString *)byteString __attribute__((swift_name("write(byteString:)")));

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)writeSource:(PrimalSharedOkioBuffer *)source byteCount:(int64_t)byteCount error:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("write(source:byteCount:)")));
- (PrimalSharedOkioBuffer *)writeSource:(id<PrimalSharedOkioSource>)source byteCount:(int64_t)byteCount __attribute__((swift_name("write(source:byteCount_:)")));
- (PrimalSharedOkioBuffer *)writeSource:(PrimalSharedKotlinByteArray *)source offset:(int32_t)offset byteCount:(int32_t)byteCount __attribute__((swift_name("write(source:offset:byteCount:)")));
- (PrimalSharedOkioBuffer *)writeByteString:(PrimalSharedOkioByteString *)byteString offset:(int32_t)offset byteCount:(int32_t)byteCount __attribute__((swift_name("write(byteString:offset:byteCount:)")));
- (int64_t)writeAllSource:(id<PrimalSharedOkioSource>)source __attribute__((swift_name("writeAll(source:)")));
- (PrimalSharedOkioBuffer *)writeByteB:(int32_t)b __attribute__((swift_name("writeByte(b:)")));
- (PrimalSharedOkioBuffer *)writeDecimalLongV:(int64_t)v __attribute__((swift_name("writeDecimalLong(v:)")));
- (PrimalSharedOkioBuffer *)writeHexadecimalUnsignedLongV:(int64_t)v __attribute__((swift_name("writeHexadecimalUnsignedLong(v:)")));
- (PrimalSharedOkioBuffer *)writeIntI:(int32_t)i __attribute__((swift_name("writeInt(i:)")));
- (PrimalSharedOkioBuffer *)writeIntLeI:(int32_t)i __attribute__((swift_name("writeIntLe(i:)")));
- (PrimalSharedOkioBuffer *)writeLongV:(int64_t)v __attribute__((swift_name("writeLong(v:)")));
- (PrimalSharedOkioBuffer *)writeLongLeV:(int64_t)v __attribute__((swift_name("writeLongLe(v:)")));
- (PrimalSharedOkioBuffer *)writeShortS:(int32_t)s __attribute__((swift_name("writeShort(s:)")));
- (PrimalSharedOkioBuffer *)writeShortLeS:(int32_t)s __attribute__((swift_name("writeShortLe(s:)")));
- (PrimalSharedOkioBuffer *)writeUtf8String:(NSString *)string __attribute__((swift_name("writeUtf8(string:)")));
- (PrimalSharedOkioBuffer *)writeUtf8String:(NSString *)string beginIndex:(int32_t)beginIndex endIndex:(int32_t)endIndex __attribute__((swift_name("writeUtf8(string:beginIndex:endIndex:)")));
- (PrimalSharedOkioBuffer *)writeUtf8CodePointCodePoint:(int32_t)codePoint __attribute__((swift_name("writeUtf8CodePoint(codePoint:)")));
@end

__attribute__((swift_name("OkioIOException")))
@interface PrimalSharedOkioIOException : PrimalSharedKotlinException
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithMessage:(NSString * _Nullable)message __attribute__((swift_name("init(message:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithMessage:(NSString * _Nullable)message cause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(message:cause:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCause:(PrimalSharedKotlinThrowable * _Nullable)cause __attribute__((swift_name("init(cause:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((swift_name("OkioTimeout")))
@interface PrimalSharedOkioTimeout : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedOkioTimeoutCompanion *companion __attribute__((swift_name("companion")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_jsonJsonElement.Companion")))
@interface PrimalSharedKotlinx_serialization_jsonJsonElementCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_jsonJsonElementCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinAbstractCoroutineContextElement")))
@interface PrimalSharedKotlinAbstractCoroutineContextElement : PrimalSharedBase <PrimalSharedKotlinCoroutineContextElement>
@property (readonly) id<PrimalSharedKotlinCoroutineContextKey> key __attribute__((swift_name("key")));
- (instancetype)initWithKey:(id<PrimalSharedKotlinCoroutineContextKey>)key __attribute__((swift_name("init(key:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinContinuationInterceptor")))
@protocol PrimalSharedKotlinContinuationInterceptor <PrimalSharedKotlinCoroutineContextElement>
@required
- (id<PrimalSharedKotlinContinuation>)interceptContinuationContinuation:(id<PrimalSharedKotlinContinuation>)continuation __attribute__((swift_name("interceptContinuation(continuation:)")));
- (void)releaseInterceptedContinuationContinuation:(id<PrimalSharedKotlinContinuation>)continuation __attribute__((swift_name("releaseInterceptedContinuation(continuation:)")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreCoroutineDispatcher")))
@interface PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher : PrimalSharedKotlinAbstractCoroutineContextElement <PrimalSharedKotlinContinuationInterceptor>
@property (class, readonly, getter=companion) PrimalSharedKotlinx_coroutines_coreCoroutineDispatcherKey *companion __attribute__((swift_name("companion")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (instancetype)initWithKey:(id<PrimalSharedKotlinCoroutineContextKey>)key __attribute__((swift_name("init(key:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (void)dispatchContext:(id<PrimalSharedKotlinCoroutineContext>)context block:(id<PrimalSharedKotlinx_coroutines_coreRunnable>)block __attribute__((swift_name("dispatch(context:block:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (void)dispatchYieldContext:(id<PrimalSharedKotlinCoroutineContext>)context block:(id<PrimalSharedKotlinx_coroutines_coreRunnable>)block __attribute__((swift_name("dispatchYield(context:block:)")));
- (id<PrimalSharedKotlinContinuation>)interceptContinuationContinuation:(id<PrimalSharedKotlinContinuation>)continuation __attribute__((swift_name("interceptContinuation(continuation:)")));
- (BOOL)isDispatchNeededContext:(id<PrimalSharedKotlinCoroutineContext>)context __attribute__((swift_name("isDispatchNeeded(context:)")));
- (PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher *)limitedParallelismParallelism:(int32_t)parallelism name:(NSString * _Nullable)name __attribute__((swift_name("limitedParallelism(parallelism:name:)")));
- (PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher *)plusOther_:(PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher *)other __attribute__((swift_name("plus(other_:)"))) __attribute__((unavailable("Operator '+' on two CoroutineDispatcher objects is meaningless. CoroutineDispatcher is a coroutine context element and `+` is a set-sum operator for coroutine contexts. The dispatcher to the right of `+` just replaces the dispatcher to the left.")));
- (void)releaseInterceptedContinuationContinuation:(id<PrimalSharedKotlinContinuation>)continuation __attribute__((swift_name("releaseInterceptedContinuation(continuation:)")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Ktor_client_coreHttpClientEngineConfig")))
@interface PrimalSharedKtor_client_coreHttpClientEngineConfig : PrimalSharedBase
@property PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher * _Nullable dispatcher __attribute__((swift_name("dispatcher")));
@property BOOL pipelining __attribute__((swift_name("pipelining")));
@property PrimalSharedKtor_client_coreProxyConfig * _Nullable proxy __attribute__((swift_name("proxy")));
@property int32_t threadsCount __attribute__((swift_name("threadsCount"))) __attribute__((unavailable("The [threadsCount] property is deprecated. Consider setting [dispatcher] instead.")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpClientConfig")))
@interface PrimalSharedKtor_client_coreHttpClientConfig<T> : PrimalSharedBase
@property BOOL developmentMode __attribute__((swift_name("developmentMode"))) __attribute__((deprecated("Development mode is no longer required. The property will be removed in the future.")));
@property BOOL expectSuccess __attribute__((swift_name("expectSuccess")));
@property BOOL followRedirects __attribute__((swift_name("followRedirects")));
@property BOOL useDefaultTransformers __attribute__((swift_name("useDefaultTransformers")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (PrimalSharedKtor_client_coreHttpClientConfig<T> *)clone __attribute__((swift_name("clone()")));
- (void)engineBlock:(void (^)(T))block __attribute__((swift_name("engine(block:)")));
- (void)installClient:(PrimalSharedKtor_client_coreHttpClient *)client __attribute__((swift_name("install(client:)")));
- (void)installPlugin:(id<PrimalSharedKtor_client_coreHttpClientPlugin>)plugin configure:(void (^)(id))configure __attribute__((swift_name("install(plugin:configure:)")));
- (void)installKey:(NSString *)key block:(void (^)(PrimalSharedKtor_client_coreHttpClient *))block __attribute__((swift_name("install(key:block:)")));
- (void)plusAssignOther:(PrimalSharedKtor_client_coreHttpClientConfig<T> *)other __attribute__((swift_name("plusAssign(other:)")));
@end

__attribute__((swift_name("Ktor_client_coreHttpClientEngineCapability")))
@protocol PrimalSharedKtor_client_coreHttpClientEngineCapability
@required
@end

__attribute__((swift_name("Ktor_utilsAttributes")))
@protocol PrimalSharedKtor_utilsAttributes
@required
- (id)computeIfAbsentKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key block:(id (^)(void))block __attribute__((swift_name("computeIfAbsent(key:block:)")));
- (BOOL)containsKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("contains(key:)")));
- (id)getKey_:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("get(key_:)")));
- (id _Nullable)getOrNullKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("getOrNull(key:)")));
- (void)putKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key value:(id)value __attribute__((swift_name("put(key:value:)")));
- (void)removeKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("remove(key:)")));
- (id)takeKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("take(key:)")));
- (id _Nullable)takeOrNullKey:(PrimalSharedKtor_utilsAttributeKey<id> *)key __attribute__((swift_name("takeOrNull(key:)")));
@property (readonly) NSArray<PrimalSharedKtor_utilsAttributeKey<id> *> *allKeys __attribute__((swift_name("allKeys")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_eventsEvents")))
@interface PrimalSharedKtor_eventsEvents : PrimalSharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (void)raiseDefinition:(PrimalSharedKtor_eventsEventDefinition<id> *)definition value:(id _Nullable)value __attribute__((swift_name("raise(definition:value:)")));
- (id<PrimalSharedKotlinx_coroutines_coreDisposableHandle>)subscribeDefinition:(PrimalSharedKtor_eventsEventDefinition<id> *)definition handler:(void (^)(id _Nullable))handler __attribute__((swift_name("subscribe(definition:handler:)")));
- (void)unsubscribeDefinition:(PrimalSharedKtor_eventsEventDefinition<id> *)definition handler:(void (^)(id _Nullable))handler __attribute__((swift_name("unsubscribe(definition:handler:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpReceivePipeline")))
@interface PrimalSharedKtor_client_coreHttpReceivePipeline : PrimalSharedKtor_utilsPipeline<PrimalSharedKtor_client_coreHttpResponse *, PrimalSharedKotlinUnit *>
@property (class, readonly, getter=companion) PrimalSharedKtor_client_coreHttpReceivePipelinePhases *companion __attribute__((swift_name("companion")));
@property (readonly) BOOL developmentMode __attribute__((swift_name("developmentMode")));
- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode __attribute__((swift_name("init(developmentMode:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithPhases:(PrimalSharedKotlinArray<PrimalSharedKtor_utilsPipelinePhase *> *)phases __attribute__((swift_name("init(phases:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithPhase:(PrimalSharedKtor_utilsPipelinePhase *)phase interceptors:(NSArray<id<PrimalSharedKotlinSuspendFunction2>> *)interceptors __attribute__((swift_name("init(phase:interceptors:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpRequestPipeline")))
@interface PrimalSharedKtor_client_coreHttpRequestPipeline : PrimalSharedKtor_utilsPipeline<id, PrimalSharedKtor_client_coreHttpRequestBuilder *>
@property (class, readonly, getter=companion) PrimalSharedKtor_client_coreHttpRequestPipelinePhases *companion __attribute__((swift_name("companion")));
@property (readonly) BOOL developmentMode __attribute__((swift_name("developmentMode")));
- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode __attribute__((swift_name("init(developmentMode:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithPhases:(PrimalSharedKotlinArray<PrimalSharedKtor_utilsPipelinePhase *> *)phases __attribute__((swift_name("init(phases:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithPhase:(PrimalSharedKtor_utilsPipelinePhase *)phase interceptors:(NSArray<id<PrimalSharedKotlinSuspendFunction2>> *)interceptors __attribute__((swift_name("init(phase:interceptors:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpResponsePipeline")))
@interface PrimalSharedKtor_client_coreHttpResponsePipeline : PrimalSharedKtor_utilsPipeline<PrimalSharedKtor_client_coreHttpResponseContainer *, PrimalSharedKtor_client_coreHttpClientCall *>
@property (class, readonly, getter=companion) PrimalSharedKtor_client_coreHttpResponsePipelinePhases *companion __attribute__((swift_name("companion")));
@property (readonly) BOOL developmentMode __attribute__((swift_name("developmentMode")));
- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode __attribute__((swift_name("init(developmentMode:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithPhases:(PrimalSharedKotlinArray<PrimalSharedKtor_utilsPipelinePhase *> *)phases __attribute__((swift_name("init(phases:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithPhase:(PrimalSharedKtor_utilsPipelinePhase *)phase interceptors:(NSArray<id<PrimalSharedKotlinSuspendFunction2>> *)interceptors __attribute__((swift_name("init(phase:interceptors:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpSendPipeline")))
@interface PrimalSharedKtor_client_coreHttpSendPipeline : PrimalSharedKtor_utilsPipeline<id, PrimalSharedKtor_client_coreHttpRequestBuilder *>
@property (class, readonly, getter=companion) PrimalSharedKtor_client_coreHttpSendPipelinePhases *companion __attribute__((swift_name("companion")));
@property (readonly) BOOL developmentMode __attribute__((swift_name("developmentMode")));
- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode __attribute__((swift_name("init(developmentMode:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithPhases:(PrimalSharedKotlinArray<PrimalSharedKtor_utilsPipelinePhase *> *)phases __attribute__((swift_name("init(phases:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (instancetype)initWithPhase:(PrimalSharedKtor_utilsPipelinePhase *)phase interceptors:(NSArray<id<PrimalSharedKotlinSuspendFunction2>> *)interceptors __attribute__((swift_name("init(phase:interceptors:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_datetimeInstant.Companion")))
@interface PrimalSharedKotlinx_datetimeInstantCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinx_datetimeInstantCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKotlinx_datetimeInstant *DISTANT_FUTURE __attribute__((swift_name("DISTANT_FUTURE")));
@property (readonly) PrimalSharedKotlinx_datetimeInstant *DISTANT_PAST __attribute__((swift_name("DISTANT_PAST")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKotlinx_datetimeInstant *)fromEpochMillisecondsEpochMilliseconds:(int64_t)epochMilliseconds __attribute__((swift_name("fromEpochMilliseconds(epochMilliseconds:)")));
- (PrimalSharedKotlinx_datetimeInstant *)fromEpochSecondsEpochSeconds:(int64_t)epochSeconds nanosecondAdjustment:(int32_t)nanosecondAdjustment __attribute__((swift_name("fromEpochSeconds(epochSeconds:nanosecondAdjustment:)")));
- (PrimalSharedKotlinx_datetimeInstant *)fromEpochSecondsEpochSeconds:(int64_t)epochSeconds nanosecondAdjustment_:(int64_t)nanosecondAdjustment __attribute__((swift_name("fromEpochSeconds(epochSeconds:nanosecondAdjustment_:)")));
- (PrimalSharedKotlinx_datetimeInstant *)now __attribute__((swift_name("now()"))) __attribute__((unavailable("Use Clock.System.now() instead")));
- (PrimalSharedKotlinx_datetimeInstant *)parseInput:(id)input format:(id<PrimalSharedKotlinx_datetimeDateTimeFormat>)format __attribute__((swift_name("parse(input:format:)")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinIntProgression.Companion")))
@interface PrimalSharedKotlinIntProgressionCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinIntProgressionCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKotlinIntProgression *)fromClosedRangeRangeStart:(int32_t)rangeStart rangeEnd:(int32_t)rangeEnd step:(int32_t)step __attribute__((swift_name("fromClosedRange(rangeStart:rangeEnd:step:)")));
@end

__attribute__((swift_name("KotlinIntIterator")))
@interface PrimalSharedKotlinIntIterator : PrimalSharedBase <PrimalSharedKotlinIterator>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (PrimalSharedInt *)next __attribute__((swift_name("next()")));
- (int32_t)nextInt __attribute__((swift_name("nextInt()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinIntRange.Companion")))
@interface PrimalSharedKotlinIntRangeCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinIntRangeCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKotlinIntRange *EMPTY __attribute__((swift_name("EMPTY")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("BignumBigNumberCreator")))
@protocol PrimalSharedBignumBigNumberCreator
@required
- (id _Nullable)fromBigIntegerBigInteger:(PrimalSharedBignumBigInteger *)bigInteger __attribute__((swift_name("fromBigInteger(bigInteger:)")));
- (id _Nullable)fromByteByte:(int8_t)byte __attribute__((swift_name("fromByte(byte:)")));
- (id _Nullable)fromIntInt:(int32_t)int_ __attribute__((swift_name("fromInt(int:)")));
- (id _Nullable)fromLongLong:(int64_t)long_ __attribute__((swift_name("fromLong(long:)")));
- (id _Nullable)fromShortShort:(int16_t)short_ __attribute__((swift_name("fromShort(short:)")));
- (id _Nullable)fromUByteUByte:(uint8_t)uByte __attribute__((swift_name("fromUByte(uByte:)")));
- (id _Nullable)fromUIntUInt:(uint32_t)uInt __attribute__((swift_name("fromUInt(uInt:)")));
- (id _Nullable)fromULongULong:(uint64_t)uLong __attribute__((swift_name("fromULong(uLong:)")));
- (id _Nullable)fromUShortUShort:(uint16_t)uShort __attribute__((swift_name("fromUShort(uShort:)")));
- (id _Nullable)parseStringString:(NSString *)string base:(int32_t)base __attribute__((swift_name("parseString(string:base:)")));
- (id _Nullable)tryFromDoubleDouble:(double)double_ exactRequired:(BOOL)exactRequired __attribute__((swift_name("tryFromDouble(double:exactRequired:)")));
- (id _Nullable)tryFromFloatFloat:(float)float_ exactRequired:(BOOL)exactRequired __attribute__((swift_name("tryFromFloat(float:exactRequired:)")));
@property (readonly) id _Nullable ONE __attribute__((swift_name("ONE")));
@property (readonly) id _Nullable TEN __attribute__((swift_name("TEN")));
@property (readonly) id _Nullable TWO __attribute__((swift_name("TWO")));
@property (readonly) id _Nullable ZERO __attribute__((swift_name("ZERO")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumBigDecimal.Companion")))
@interface PrimalSharedBignumBigDecimalCompanion : PrimalSharedBase <PrimalSharedBignumBigNumberCreator>
@property (class, readonly, getter=shared) PrimalSharedBignumBigDecimalCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedBignumBigDecimal *ONE __attribute__((swift_name("ONE")));
@property (readonly) PrimalSharedBignumBigDecimal *TEN __attribute__((swift_name("TEN")));
@property (readonly) PrimalSharedBignumBigDecimal *TWO __attribute__((swift_name("TWO")));
@property (readonly) PrimalSharedBignumBigDecimal *ZERO __attribute__((swift_name("ZERO")));
@property BOOL useToStringExpanded __attribute__((swift_name("useToStringExpanded")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedBignumBigDecimal *)fromBigDecimalBigDecimal:(PrimalSharedBignumBigDecimal *)bigDecimal decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromBigDecimal(bigDecimal:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromBigIntegerBigInteger:(PrimalSharedBignumBigInteger *)bigInteger __attribute__((swift_name("fromBigInteger(bigInteger:)")));
- (PrimalSharedBignumBigDecimal *)fromBigIntegerBigInteger:(PrimalSharedBignumBigInteger *)bigInteger decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromBigInteger(bigInteger:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromBigIntegerWithExponentBigInteger:(PrimalSharedBignumBigInteger *)bigInteger exponent:(int64_t)exponent decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromBigIntegerWithExponent(bigInteger:exponent:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromByteByte:(int8_t)byte __attribute__((swift_name("fromByte(byte:)")));
- (PrimalSharedBignumBigDecimal *)fromByteByte:(int8_t)byte decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromByte(byte:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromByteAsSignificandByte:(int8_t)byte decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromByteAsSignificand(byte:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromByteWithExponentByte:(int8_t)byte exponent:(int64_t)exponent decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromByteWithExponent(byte:exponent:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromDoubleDouble:(double)double_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromDouble(double:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromFloatFloat:(float)float_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromFloat(float:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromIntInt:(int32_t)int_ __attribute__((swift_name("fromInt(int:)")));
- (PrimalSharedBignumBigDecimal *)fromIntInt:(int32_t)int_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromInt(int:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromIntAsSignificandInt:(int32_t)int_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromIntAsSignificand(int:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromIntWithExponentInt:(int32_t)int_ exponent:(int64_t)exponent decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromIntWithExponent(int:exponent:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromLongLong:(int64_t)long_ __attribute__((swift_name("fromLong(long:)")));
- (PrimalSharedBignumBigDecimal *)fromLongLong:(int64_t)long_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromLong(long:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromLongAsSignificandLong:(int64_t)long_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromLongAsSignificand(long:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromLongWithExponentLong:(int64_t)long_ exponent:(int64_t)exponent decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromLongWithExponent(long:exponent:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromShortShort:(int16_t)short_ __attribute__((swift_name("fromShort(short:)")));
- (PrimalSharedBignumBigDecimal *)fromShortShort:(int16_t)short_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromShort(short:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromShortAsSignificandShort:(int16_t)short_ decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromShortAsSignificand(short:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromShortWithExponentShort:(int16_t)short_ exponent:(int64_t)exponent decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromShortWithExponent(short:exponent:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromUByteUByte:(uint8_t)uByte __attribute__((swift_name("fromUByte(uByte:)")));
- (PrimalSharedBignumBigDecimal *)fromUByteUByte:(uint8_t)uByte decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromUByte(uByte:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromUIntUInt:(uint32_t)uInt __attribute__((swift_name("fromUInt(uInt:)")));
- (PrimalSharedBignumBigDecimal *)fromUIntUInt:(uint32_t)uInt decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromUInt(uInt:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromULongULong:(uint64_t)uLong __attribute__((swift_name("fromULong(uLong:)")));
- (PrimalSharedBignumBigDecimal *)fromULongULong:(uint64_t)uLong decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromULong(uLong:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)fromUShortUShort:(uint16_t)uShort __attribute__((swift_name("fromUShort(uShort:)")));
- (PrimalSharedBignumBigDecimal *)fromUShortUShort:(uint16_t)uShort decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("fromUShort(uShort:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)handleZeroRoundingSignificand:(PrimalSharedBignumBigInteger *)significand exponent:(int64_t)exponent decimalMode:(PrimalSharedBignumDecimalMode *)decimalMode __attribute__((swift_name("handleZeroRounding(significand:exponent:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)parseStringString:(NSString *)string __attribute__((swift_name("parseString(string:)")));
- (PrimalSharedBignumBigDecimal *)parseStringString:(NSString *)string base:(int32_t)base __attribute__((swift_name("parseString(string:base:)")));
- (PrimalSharedBignumBigDecimal *)parseStringWithModeFloatingPointString:(NSString *)floatingPointString decimalMode:(PrimalSharedBignumDecimalMode * _Nullable)decimalMode __attribute__((swift_name("parseStringWithMode(floatingPointString:decimalMode:)")));
- (PrimalSharedBignumBigDecimal *)tryFromDoubleDouble:(double)double_ exactRequired:(BOOL)exactRequired __attribute__((swift_name("tryFromDouble(double:exactRequired:)")));
- (PrimalSharedBignumBigDecimal *)tryFromFloatFloat:(float)float_ exactRequired:(BOOL)exactRequired __attribute__((swift_name("tryFromFloat(float:exactRequired:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumDecimalMode")))
@interface PrimalSharedBignumDecimalMode : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedBignumDecimalModeCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t decimalPrecision __attribute__((swift_name("decimalPrecision")));
@property (readonly) BOOL isPrecisionUnlimited __attribute__((swift_name("isPrecisionUnlimited")));
@property (readonly) PrimalSharedBignumRoundingMode *roundingMode __attribute__((swift_name("roundingMode")));
@property (readonly) int64_t scale __attribute__((swift_name("scale")));
@property (readonly) BOOL usingScale __attribute__((swift_name("usingScale")));
- (instancetype)initWithDecimalPrecision:(int64_t)decimalPrecision roundingMode:(PrimalSharedBignumRoundingMode *)roundingMode scale:(int64_t)scale __attribute__((swift_name("init(decimalPrecision:roundingMode:scale:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedBignumDecimalMode *)doCopyDecimalPrecision:(int64_t)decimalPrecision roundingMode:(PrimalSharedBignumRoundingMode *)roundingMode scale:(int64_t)scale __attribute__((swift_name("doCopy(decimalPrecision:roundingMode:scale:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("BignumBitwiseCapable")))
@protocol PrimalSharedBignumBitwiseCapable
@required
- (id _Nullable)andOther:(id _Nullable)other __attribute__((swift_name("and(other:)")));
- (BOOL)bitAtPosition:(int64_t)position __attribute__((swift_name("bitAt(position:)")));
- (int32_t)bitLength __attribute__((swift_name("bitLength()")));
- (id _Nullable)not __attribute__((swift_name("not()")));
- (id _Nullable)orOther:(id _Nullable)other __attribute__((swift_name("or(other:)")));
- (id _Nullable)setBitAtPosition:(int64_t)position bit:(BOOL)bit __attribute__((swift_name("setBitAt(position:bit:)")));
- (id _Nullable)shlPlaces:(int32_t)places __attribute__((swift_name("shl(places:)")));
- (id _Nullable)shrPlaces:(int32_t)places __attribute__((swift_name("shr(places:)")));
- (id _Nullable)xorOther:(id _Nullable)other __attribute__((swift_name("xor(other:)")));
@end

__attribute__((swift_name("BignumByteArraySerializable")))
@protocol PrimalSharedBignumByteArraySerializable
@required
- (PrimalSharedKotlinByteArray *)toByteArray __attribute__((swift_name("toByteArray()")));
- (id)toUByteArray __attribute__((swift_name("toUByteArray()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumBigInteger")))
@interface PrimalSharedBignumBigInteger : PrimalSharedBase <PrimalSharedBignumBigNumber, PrimalSharedBignumBitwiseCapable, PrimalSharedKotlinComparable, PrimalSharedBignumByteArraySerializable>
@property (class, readonly, getter=companion) PrimalSharedBignumBigIntegerCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t numberOfWords __attribute__((swift_name("numberOfWords")));
@property NSString * _Nullable stringRepresentation __attribute__((swift_name("stringRepresentation")));
- (instancetype)initWithByte:(int8_t)byte __attribute__((swift_name("init(byte:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithInt:(int32_t)int_ __attribute__((swift_name("init(int:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithLong:(int64_t)long_ __attribute__((swift_name("init(long:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithShort:(int16_t)short_ __attribute__((swift_name("init(short:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedBignumBigInteger *)abs __attribute__((swift_name("abs()")));
- (PrimalSharedBignumBigInteger *)addOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("add(other:)")));
- (PrimalSharedBignumBigInteger *)andOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("and(other:)")));
- (BOOL)bitAtPosition:(int64_t)position __attribute__((swift_name("bitAt(position:)")));
- (int32_t)bitLength __attribute__((swift_name("bitLength()")));
- (int8_t)byteValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("byteValue(exactRequired:)")));
- (int32_t)compareOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("compare(other:)")));
- (int32_t)compareDoubleAndBigIntDouble:(double)double_ comparisonBlock:(PrimalSharedInt *(^)(PrimalSharedBignumBigInteger *))comparisonBlock __attribute__((swift_name("compareDoubleAndBigInt(double:comparisonBlock:)")));
- (int32_t)compareFloatAndBigIntFloat:(float)float_ comparisonBlock:(PrimalSharedInt *(^)(PrimalSharedBignumBigInteger *))comparisonBlock __attribute__((swift_name("compareFloatAndBigInt(float:comparisonBlock:)")));
- (int32_t)compareToOther:(id)other __attribute__((swift_name("compareTo(other:)")));
- (int32_t)compareToOther_:(id)other __attribute__((swift_name("compareTo(other_:)")));
- (PrimalSharedBignumBigInteger *)dec __attribute__((swift_name("dec()")));
- (PrimalSharedBignumBigInteger *)divideOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("divide(other:)")));
- (PrimalSharedKotlinPair<PrimalSharedBignumBigInteger *, PrimalSharedBignumBigInteger *> *)divideAndRemainderOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("divideAndRemainder(other:)")));
- (PrimalSharedBignumBigIntegerQuotientAndRemainder *)divremOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("divrem(other:)")));
- (double)doubleValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("doubleValue(exactRequired:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (PrimalSharedBignumBigInteger *)factorial __attribute__((swift_name("factorial()")));
- (float)floatValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("floatValue(exactRequired:)")));
- (PrimalSharedBignumBigInteger *)gcdOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("gcd(other:)")));
- (id)getBackingArrayCopy __attribute__((swift_name("getBackingArrayCopy()")));
- (id<PrimalSharedBignumBigNumberCreator>)getCreator __attribute__((swift_name("getCreator()")));
- (PrimalSharedBignumBigInteger *)getInstance __attribute__((swift_name("getInstance()")));
- (PrimalSharedBignumSign *)getSign __attribute__((swift_name("getSign()")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (PrimalSharedBignumBigInteger *)inc __attribute__((swift_name("inc()")));
- (int32_t)intValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("intValue(exactRequired:)")));
- (BOOL)isZero __attribute__((swift_name("isZero()")));
- (int64_t)longValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("longValue(exactRequired:)")));
- (PrimalSharedBignumBigInteger *)modModulo:(PrimalSharedBignumBigInteger *)modulo __attribute__((swift_name("mod(modulo:)")));
- (PrimalSharedBignumBigInteger *)modInverseModulo:(PrimalSharedBignumBigInteger *)modulo __attribute__((swift_name("modInverse(modulo:)")));
- (PrimalSharedBignumBigInteger *)multiplyOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("multiply(other:)")));
- (PrimalSharedBignumBigInteger *)negate __attribute__((swift_name("negate()")));
- (PrimalSharedBignumBigInteger *)not __attribute__((swift_name("not()")));
- (int64_t)numberOfDecimalDigits __attribute__((swift_name("numberOfDecimalDigits()")));
- (PrimalSharedBignumBigInteger *)orOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("or(other:)")));
- (PrimalSharedBignumBigInteger *)powExponent__:(PrimalSharedBignumBigInteger *)exponent __attribute__((swift_name("pow(exponent__:)")));
- (PrimalSharedBignumBigInteger *)powExponent:(int32_t)exponent __attribute__((swift_name("pow(exponent:)")));
- (PrimalSharedBignumBigInteger *)powExponent_:(int64_t)exponent __attribute__((swift_name("pow(exponent_:)")));
- (PrimalSharedBignumBigIntegerBigIntegerRange *)rangeToOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("rangeTo(other:)")));
- (PrimalSharedBignumBigInteger *)remainderOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("remainder(other:)")));
- (void)secureOverwrite __attribute__((swift_name("secureOverwrite()")));
- (PrimalSharedBignumBigInteger *)setBitAtPosition:(int64_t)position bit:(BOOL)bit __attribute__((swift_name("setBitAt(position:bit:)")));
- (PrimalSharedBignumBigInteger *)shlPlaces:(int32_t)places __attribute__((swift_name("shl(places:)")));
- (int16_t)shortValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("shortValue(exactRequired:)")));
- (PrimalSharedBignumBigInteger *)shrPlaces:(int32_t)places __attribute__((swift_name("shr(places:)")));
- (int32_t)signum __attribute__((swift_name("signum()")));
- (PrimalSharedBignumBigInteger *)sqrt __attribute__((swift_name("sqrt()")));
- (PrimalSharedBignumBigIntegerSqareRootAndRemainder *)sqrtAndRemainder __attribute__((swift_name("sqrtAndRemainder()")));
- (PrimalSharedBignumBigInteger *)subtractOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("subtract(other:)")));
- (NSString *)timesChar:(unichar)char_ __attribute__((swift_name("times(char:)")));
- (PrimalSharedKotlinByteArray *)toByteArray __attribute__((swift_name("toByteArray()")));
- (PrimalSharedBignumModularBigInteger *)toModularBigIntegerModulo:(PrimalSharedBignumBigInteger *)modulo __attribute__((swift_name("toModularBigInteger(modulo:)")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSString *)toStringBase:(int32_t)base __attribute__((swift_name("toString(base:)")));
- (id)toUByteArray __attribute__((swift_name("toUByteArray()")));
- (uint8_t)ubyteValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ubyteValue(exactRequired:)")));
- (uint32_t)uintValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("uintValue(exactRequired:)")));
- (uint64_t)ulongValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ulongValue(exactRequired:)")));
- (PrimalSharedBignumBigInteger *)unaryMinus __attribute__((swift_name("unaryMinus()")));
- (uint16_t)ushortValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ushortValue(exactRequired:)")));
- (PrimalSharedBignumBigInteger *)xorOther:(PrimalSharedBignumBigInteger *)other __attribute__((swift_name("xor(other:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumRoundingMode")))
@interface PrimalSharedBignumRoundingMode : PrimalSharedKotlinEnum<PrimalSharedBignumRoundingMode *>
@property (class, readonly) PrimalSharedBignumRoundingMode *floor __attribute__((swift_name("floor")));
@property (class, readonly) PrimalSharedBignumRoundingMode *ceiling __attribute__((swift_name("ceiling")));
@property (class, readonly) PrimalSharedBignumRoundingMode *awayFromZero __attribute__((swift_name("awayFromZero")));
@property (class, readonly) PrimalSharedBignumRoundingMode *towardsZero __attribute__((swift_name("towardsZero")));
@property (class, readonly) PrimalSharedBignumRoundingMode *none __attribute__((swift_name("none")));
@property (class, readonly) PrimalSharedBignumRoundingMode *roundHalfAwayFromZero __attribute__((swift_name("roundHalfAwayFromZero")));
@property (class, readonly) PrimalSharedBignumRoundingMode *roundHalfTowardsZero __attribute__((swift_name("roundHalfTowardsZero")));
@property (class, readonly) PrimalSharedBignumRoundingMode *roundHalfCeiling __attribute__((swift_name("roundHalfCeiling")));
@property (class, readonly) PrimalSharedBignumRoundingMode *roundHalfFloor __attribute__((swift_name("roundHalfFloor")));
@property (class, readonly) PrimalSharedBignumRoundingMode *roundHalfToEven __attribute__((swift_name("roundHalfToEven")));
@property (class, readonly) PrimalSharedBignumRoundingMode *roundHalfToOdd __attribute__((swift_name("roundHalfToOdd")));
@property (class, readonly) NSArray<PrimalSharedBignumRoundingMode *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedBignumRoundingMode *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsAttributeKey")))
@interface PrimalSharedKtor_utilsAttributeKey<T> : PrimalSharedBase
@property (readonly) NSString *name __attribute__((swift_name("name")));

/**
 * @note annotations
 *   kotlin.jvm.JvmOverloads
*/
- (instancetype)initWithName:(NSString *)name type:(PrimalSharedKtor_utilsTypeInfo *)type __attribute__((swift_name("init(name:type:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_utilsAttributeKey<T> *)doCopyName:(NSString *)name type:(PrimalSharedKtor_utilsTypeInfo *)type __attribute__((swift_name("doCopy(name:type:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Ktor_utilsStringValues")))
@protocol PrimalSharedKtor_utilsStringValues
@required
- (BOOL)containsName:(NSString *)name __attribute__((swift_name("contains(name:)")));
- (BOOL)containsName:(NSString *)name value:(NSString *)value __attribute__((swift_name("contains(name:value:)")));
- (NSSet<id<PrimalSharedKotlinMapEntry>> *)entries __attribute__((swift_name("entries()")));
- (void)forEachBody:(void (^)(NSString *, NSArray<NSString *> *))body __attribute__((swift_name("forEach(body:)")));
- (NSString * _Nullable)getName:(NSString *)name __attribute__((swift_name("get(name:)")));
- (NSArray<NSString *> * _Nullable)getAllName:(NSString *)name __attribute__((swift_name("getAll(name:)")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (NSSet<NSString *> *)names __attribute__((swift_name("names()")));
@property (readonly) BOOL caseInsensitiveName __attribute__((swift_name("caseInsensitiveName")));
@end

__attribute__((swift_name("Ktor_httpHeaders")))
@protocol PrimalSharedKtor_httpHeaders <PrimalSharedKtor_utilsStringValues>
@required
@end

__attribute__((swift_name("Ktor_httpHeaderValueWithParameters")))
@interface PrimalSharedKtor_httpHeaderValueWithParameters : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedKtor_httpHeaderValueWithParametersCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *content __attribute__((swift_name("content")));
@property (readonly) NSArray<PrimalSharedKtor_httpHeaderValueParam *> *parameters __attribute__((swift_name("parameters")));
- (instancetype)initWithContent:(NSString *)content parameters:(NSArray<PrimalSharedKtor_httpHeaderValueParam *> *)parameters __attribute__((swift_name("init(content:parameters:)"))) __attribute__((objc_designated_initializer));
- (NSString * _Nullable)parameterName:(NSString *)name __attribute__((swift_name("parameter(name:)")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpContentType")))
@interface PrimalSharedKtor_httpContentType : PrimalSharedKtor_httpHeaderValueWithParameters
@property (class, readonly, getter=companion) PrimalSharedKtor_httpContentTypeCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *contentSubtype __attribute__((swift_name("contentSubtype")));
@property (readonly) NSString *contentType __attribute__((swift_name("contentType")));
- (instancetype)initWithContentType:(NSString *)contentType contentSubtype:(NSString *)contentSubtype parameters:(NSArray<PrimalSharedKtor_httpHeaderValueParam *> *)parameters __attribute__((swift_name("init(contentType:contentSubtype:parameters:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithContent:(NSString *)content parameters:(NSArray<PrimalSharedKtor_httpHeaderValueParam *> *)parameters __attribute__((swift_name("init(content:parameters:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)matchPattern:(PrimalSharedKtor_httpContentType *)pattern __attribute__((swift_name("match(pattern:)")));
- (BOOL)matchPattern_:(NSString *)pattern __attribute__((swift_name("match(pattern_:)")));
- (PrimalSharedKtor_httpContentType *)withParameterName:(NSString *)name value:(NSString *)value __attribute__((swift_name("withParameter(name:value:)")));
- (PrimalSharedKtor_httpContentType *)withoutParameters __attribute__((swift_name("withoutParameters()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHttpStatusCode")))
@interface PrimalSharedKtor_httpHttpStatusCode : PrimalSharedBase <PrimalSharedKotlinComparable>
@property (class, readonly, getter=companion) PrimalSharedKtor_httpHttpStatusCodeCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *description_ __attribute__((swift_name("description_")));
@property (readonly) int32_t value __attribute__((swift_name("value")));
- (instancetype)initWithValue:(int32_t)value description:(NSString *)description __attribute__((swift_name("init(value:description:)"))) __attribute__((objc_designated_initializer));
- (int32_t)compareToOther:(PrimalSharedKtor_httpHttpStatusCode *)other __attribute__((swift_name("compareTo(other:)")));
- (PrimalSharedKtor_httpHttpStatusCode *)doCopyValue:(int32_t)value description:(NSString *)description __attribute__((swift_name("doCopy(value:description:)")));
- (PrimalSharedKtor_httpHttpStatusCode *)descriptionValue:(NSString *)value __attribute__((swift_name("description(value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Kotlinx_io_coreRawSource")))
@protocol PrimalSharedKotlinx_io_coreRawSource <PrimalSharedKotlinAutoCloseable>
@required
- (int64_t)readAtMostToSink:(PrimalSharedKotlinx_io_coreBuffer *)sink byteCount:(int64_t)byteCount __attribute__((swift_name("readAtMostTo(sink:byteCount:)")));
@end

__attribute__((swift_name("Kotlinx_io_coreSource")))
@protocol PrimalSharedKotlinx_io_coreSource <PrimalSharedKotlinx_io_coreRawSource>
@required
- (BOOL)exhausted __attribute__((swift_name("exhausted()")));
- (id<PrimalSharedKotlinx_io_coreSource>)peek __attribute__((swift_name("peek()")));
- (int32_t)readAtMostToSink:(PrimalSharedKotlinByteArray *)sink startIndex:(int32_t)startIndex endIndex:(int32_t)endIndex __attribute__((swift_name("readAtMostTo(sink:startIndex:endIndex:)")));
- (int8_t)readByte __attribute__((swift_name("readByte()")));
- (int32_t)readInt __attribute__((swift_name("readInt()")));
- (int64_t)readLong __attribute__((swift_name("readLong()")));
- (int16_t)readShort __attribute__((swift_name("readShort()")));
- (void)readToSink:(id<PrimalSharedKotlinx_io_coreRawSink>)sink byteCount:(int64_t)byteCount __attribute__((swift_name("readTo(sink:byteCount:)")));
- (BOOL)requestByteCount:(int64_t)byteCount __attribute__((swift_name("request(byteCount:)")));
- (void)requireByteCount:(int64_t)byteCount __attribute__((swift_name("require(byteCount:)")));
- (void)skipByteCount:(int64_t)byteCount __attribute__((swift_name("skip(byteCount:)")));
- (int64_t)transferToSink:(id<PrimalSharedKotlinx_io_coreRawSink>)sink __attribute__((swift_name("transferTo(sink:)")));

/**
 * @note annotations
 *   kotlinx.io.InternalIoApi
*/
@property (readonly) PrimalSharedKotlinx_io_coreBuffer *buffer __attribute__((swift_name("buffer")));
@end

__attribute__((swift_name("Kotlinx_io_coreRawSink")))
@protocol PrimalSharedKotlinx_io_coreRawSink <PrimalSharedKotlinAutoCloseable>
@required
- (void)flush __attribute__((swift_name("flush_()")));
- (void)writeSource:(PrimalSharedKotlinx_io_coreBuffer *)source byteCount__:(int64_t)byteCount __attribute__((swift_name("write(source:byteCount___:)")));
@end

__attribute__((swift_name("Kotlinx_io_coreSink")))
@protocol PrimalSharedKotlinx_io_coreSink <PrimalSharedKotlinx_io_coreRawSink>
@required
- (void)emit_ __attribute__((swift_name("emit_()")));

/**
 * @note annotations
 *   kotlinx.io.InternalIoApi
*/
- (void)hintEmit __attribute__((swift_name("hintEmit()")));
- (int64_t)transferFromSource:(id<PrimalSharedKotlinx_io_coreRawSource>)source __attribute__((swift_name("transferFrom(source:)")));
- (void)writeSource:(id<PrimalSharedKotlinx_io_coreRawSource>)source byteCount_:(int64_t)byteCount __attribute__((swift_name("write(source:byteCount__:)")));
- (void)writeSource:(PrimalSharedKotlinByteArray *)source startIndex:(int32_t)startIndex endIndex:(int32_t)endIndex __attribute__((swift_name("write(source:startIndex:endIndex:)")));
- (void)writeByteByte:(int8_t)byte __attribute__((swift_name("writeByte(byte:)")));
- (void)writeIntInt:(int32_t)int_ __attribute__((swift_name("writeInt(int:)")));
- (void)writeLongLong:(int64_t)long_ __attribute__((swift_name("writeLong(long:)")));
- (void)writeShortShort:(int16_t)short_ __attribute__((swift_name("writeShort(short:)")));

/**
 * @note annotations
 *   kotlinx.io.InternalIoApi
*/
@property (readonly) PrimalSharedKotlinx_io_coreBuffer *buffer __attribute__((swift_name("buffer")));
@end

__attribute__((swift_name("KotlinCoroutineContextKey")))
@protocol PrimalSharedKotlinCoroutineContextKey
@required
@end

__attribute__((swift_name("Kotlinx_coroutines_coreDisposableHandle")))
@protocol PrimalSharedKotlinx_coroutines_coreDisposableHandle
@required
- (void)dispose __attribute__((swift_name("dispose()")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreChildHandle")))
@protocol PrimalSharedKotlinx_coroutines_coreChildHandle <PrimalSharedKotlinx_coroutines_coreDisposableHandle>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (BOOL)childCancelledCause:(PrimalSharedKotlinThrowable *)cause __attribute__((swift_name("childCancelled(cause:)")));

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreJob> _Nullable parent __attribute__((swift_name("parent")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreChildJob")))
@protocol PrimalSharedKotlinx_coroutines_coreChildJob <PrimalSharedKotlinx_coroutines_coreJob>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (void)parentCancelledParentJob:(id<PrimalSharedKotlinx_coroutines_coreParentJob>)parentJob __attribute__((swift_name("parentCancelled(parentJob:)")));
@end

__attribute__((swift_name("KotlinSequence")))
@protocol PrimalSharedKotlinSequence
@required
- (id<PrimalSharedKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
@end

__attribute__((swift_name("Kotlinx_coroutines_coreSelectClause0")))
@protocol PrimalSharedKotlinx_coroutines_coreSelectClause0 <PrimalSharedKotlinx_coroutines_coreSelectClause>
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsPipelinePhase")))
@interface PrimalSharedKtor_utilsPipelinePhase : PrimalSharedBase
@property (readonly) NSString *name __attribute__((swift_name("name")));
- (instancetype)initWithName:(NSString *)name __attribute__((swift_name("init(name:)"))) __attribute__((objc_designated_initializer));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpResponseData")))
@interface PrimalSharedKtor_client_coreHttpResponseData : PrimalSharedBase
@property (readonly) id body __attribute__((swift_name("body")));
@property (readonly) id<PrimalSharedKotlinCoroutineContext> callContext __attribute__((swift_name("callContext")));
@property (readonly) id<PrimalSharedKtor_httpHeaders> headers __attribute__((swift_name("headers")));
@property (readonly) PrimalSharedKtor_utilsGMTDate *requestTime __attribute__((swift_name("requestTime")));
@property (readonly) PrimalSharedKtor_utilsGMTDate *responseTime __attribute__((swift_name("responseTime")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *statusCode __attribute__((swift_name("statusCode")));
@property (readonly) PrimalSharedKtor_httpHttpProtocolVersion *version __attribute__((swift_name("version")));
- (instancetype)initWithStatusCode:(PrimalSharedKtor_httpHttpStatusCode *)statusCode requestTime:(PrimalSharedKtor_utilsGMTDate *)requestTime headers:(id<PrimalSharedKtor_httpHeaders>)headers version:(PrimalSharedKtor_httpHttpProtocolVersion *)version body:(id)body callContext:(id<PrimalSharedKotlinCoroutineContext>)callContext __attribute__((swift_name("init(statusCode:requestTime:headers:version:body:callContext:)"))) __attribute__((objc_designated_initializer));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpClientCall.Companion")))
@interface PrimalSharedKtor_client_coreHttpClientCallCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_client_coreHttpClientCallCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("Ktor_httpHttpMessage")))
@protocol PrimalSharedKtor_httpHttpMessage
@required
@property (readonly) id<PrimalSharedKtor_httpHeaders> headers __attribute__((swift_name("headers")));
@end

__attribute__((swift_name("Ktor_client_coreHttpRequest")))
@protocol PrimalSharedKtor_client_coreHttpRequest <PrimalSharedKtor_httpHttpMessage, PrimalSharedKotlinx_coroutines_coreCoroutineScope>
@required
@property (readonly) id<PrimalSharedKtor_utilsAttributes> attributes __attribute__((swift_name("attributes")));
@property (readonly) PrimalSharedKtor_client_coreHttpClientCall *call __attribute__((swift_name("call")));
@property (readonly) PrimalSharedKtor_httpOutgoingContent *content __attribute__((swift_name("content")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *method __attribute__((swift_name("method")));
@property (readonly) PrimalSharedKtor_httpUrl *url __attribute__((swift_name("url")));
@end

__attribute__((swift_name("Ktor_client_coreHttpResponse")))
@interface PrimalSharedKtor_client_coreHttpResponse : PrimalSharedBase <PrimalSharedKtor_httpHttpMessage, PrimalSharedKotlinx_coroutines_coreCoroutineScope>
@property (readonly) PrimalSharedKtor_client_coreHttpClientCall *call __attribute__((swift_name("call")));
@property (readonly) id<PrimalSharedKtor_ioByteReadChannel> rawContent __attribute__((swift_name("rawContent")));
@property (readonly) PrimalSharedKtor_utilsGMTDate *requestTime __attribute__((swift_name("requestTime")));
@property (readonly) PrimalSharedKtor_utilsGMTDate *responseTime __attribute__((swift_name("responseTime")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *status __attribute__((swift_name("status")));
@property (readonly) PrimalSharedKtor_httpHttpProtocolVersion *version __attribute__((swift_name("version")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinKDeclarationContainer")))
@protocol PrimalSharedKotlinKDeclarationContainer
@required
@end

__attribute__((swift_name("KotlinKAnnotatedElement")))
@protocol PrimalSharedKotlinKAnnotatedElement
@required
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
__attribute__((swift_name("KotlinKClassifier")))
@protocol PrimalSharedKotlinKClassifier
@required
@end

__attribute__((swift_name("KotlinKClass")))
@protocol PrimalSharedKotlinKClass <PrimalSharedKotlinKDeclarationContainer, PrimalSharedKotlinKAnnotatedElement, PrimalSharedKotlinKClassifier>
@required

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
- (BOOL)isInstanceValue:(id _Nullable)value __attribute__((swift_name("isInstance(value:)")));
@property (readonly) NSString * _Nullable qualifiedName __attribute__((swift_name("qualifiedName")));
@property (readonly) NSString * _Nullable simpleName __attribute__((swift_name("simpleName")));
@end

__attribute__((swift_name("KotlinKType")))
@protocol PrimalSharedKotlinKType
@required

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
@property (readonly) NSArray<PrimalSharedKotlinKTypeProjection *> *arguments __attribute__((swift_name("arguments")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
@property (readonly) id<PrimalSharedKotlinKClassifier> _Nullable classifier __attribute__((swift_name("classifier")));
@property (readonly) BOOL isMarkedNullable __attribute__((swift_name("isMarkedNullable")));
@end

__attribute__((swift_name("Ktor_ioJvmSerializable")))
@protocol PrimalSharedKtor_ioJvmSerializable
@required
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable(with=NormalClass(value=io/ktor/http/UrlSerializer))
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpUrl")))
@interface PrimalSharedKtor_httpUrl : PrimalSharedBase <PrimalSharedKtor_ioJvmSerializable>
@property (class, readonly, getter=companion) PrimalSharedKtor_httpUrlCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *encodedFragment __attribute__((swift_name("encodedFragment")));
@property (readonly) NSString * _Nullable encodedPassword __attribute__((swift_name("encodedPassword")));
@property (readonly) NSString *encodedPath __attribute__((swift_name("encodedPath")));
@property (readonly) NSString *encodedPathAndQuery __attribute__((swift_name("encodedPathAndQuery")));
@property (readonly) NSString *encodedQuery __attribute__((swift_name("encodedQuery")));
@property (readonly) NSString * _Nullable encodedUser __attribute__((swift_name("encodedUser")));
@property (readonly) NSString *fragment __attribute__((swift_name("fragment")));
@property (readonly) NSString *host __attribute__((swift_name("host")));
@property (readonly) id<PrimalSharedKtor_httpParameters> parameters __attribute__((swift_name("parameters")));
@property (readonly) NSString * _Nullable password __attribute__((swift_name("password")));
@property (readonly) NSArray<NSString *> *pathSegments __attribute__((swift_name("pathSegments"))) __attribute__((deprecated("\n        `pathSegments` is deprecated.\n\n        This property will contain an empty path segment at the beginning for URLs with a hostname,\n        and an empty path segment at the end for the URLs with a trailing slash. If you need to keep this behaviour please\n        use [rawSegments]. If you only need to access the meaningful parts of the path, consider using [segments] instead.\n             \n        Please decide if you need [rawSegments] or [segments] explicitly.\n        ")));
@property (readonly) int32_t port __attribute__((swift_name("port")));
@property (readonly) PrimalSharedKtor_httpURLProtocol *protocol __attribute__((swift_name("protocol")));
@property (readonly) PrimalSharedKtor_httpURLProtocol * _Nullable protocolOrNull __attribute__((swift_name("protocolOrNull")));
@property (readonly) NSArray<NSString *> *rawSegments __attribute__((swift_name("rawSegments")));
@property (readonly) NSArray<NSString *> *segments __attribute__((swift_name("segments")));
@property (readonly) int32_t specifiedPort __attribute__((swift_name("specifiedPort")));
@property (readonly) BOOL trailingQuery __attribute__((swift_name("trailingQuery")));
@property (readonly) NSString * _Nullable user __attribute__((swift_name("user")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHttpMethod")))
@interface PrimalSharedKtor_httpHttpMethod : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedKtor_httpHttpMethodCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) NSString *value __attribute__((swift_name("value")));
- (instancetype)initWithValue:(NSString *)value __attribute__((swift_name("init(value:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_httpHttpMethod *)doCopyValue:(NSString *)value __attribute__((swift_name("doCopy(value:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Paging_commonPagingDataCompanion")))
@interface PrimalSharedPaging_commonPagingDataCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedPaging_commonPagingDataCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedPaging_commonPagingData<id> *)empty __attribute__((swift_name("empty()")));

/**
 * @note annotations
 *   kotlin.jvm.JvmOverloads
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedPaging_commonPagingData<id> *)emptySourceLoadStates:(PrimalSharedPaging_commonLoadStates *)sourceLoadStates mediatorLoadStates:(PrimalSharedPaging_commonLoadStates * _Nullable)mediatorLoadStates __attribute__((swift_name("empty(sourceLoadStates:mediatorLoadStates:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedPaging_commonPagingData<id> *)fromData:(NSArray<id> *)data __attribute__((swift_name("from(data:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmOverloads
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedPaging_commonPagingData<id> *)fromData:(NSArray<id> *)data sourceLoadStates:(PrimalSharedPaging_commonLoadStates *)sourceLoadStates mediatorLoadStates:(PrimalSharedPaging_commonLoadStates * _Nullable)mediatorLoadStates __attribute__((swift_name("from(data:sourceLoadStates:mediatorLoadStates:)")));
@end

__attribute__((swift_name("KotlinLongProgression")))
@interface PrimalSharedKotlinLongProgression : PrimalSharedBase <PrimalSharedKotlinIterable>
@property (class, readonly, getter=companion) PrimalSharedKotlinLongProgressionCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int64_t first __attribute__((swift_name("first")));
@property (readonly) int64_t last __attribute__((swift_name("last")));
@property (readonly) int64_t step __attribute__((swift_name("step")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (PrimalSharedKotlinLongIterator *)iterator __attribute__((swift_name("iterator()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinLongRange")))
@interface PrimalSharedKotlinLongRange : PrimalSharedKotlinLongProgression <PrimalSharedKotlinClosedRange, PrimalSharedKotlinOpenEndRange>
@property (class, readonly, getter=companion) PrimalSharedKotlinLongRangeCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedLong *endExclusive __attribute__((swift_name("endExclusive"))) __attribute__((deprecated("Can throw an exception when it's impossible to represent the value with Long type, for example, when the range includes MAX_VALUE. It's recommended to use 'endInclusive' property that doesn't throw.")));
@property (readonly) PrimalSharedLong *endInclusive __attribute__((swift_name("endInclusive")));
@property (readonly) PrimalSharedLong *start __attribute__((swift_name("start")));
- (instancetype)initWithStart:(int64_t)start endInclusive:(int64_t)endInclusive __attribute__((swift_name("init(start:endInclusive:)"))) __attribute__((objc_designated_initializer));
- (BOOL)containsValue:(PrimalSharedLong *)value __attribute__((swift_name("contains(value:)")));
- (BOOL)containsValue_:(PrimalSharedLong *)value __attribute__((swift_name("contains(value_:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (NSString *)description __attribute__((swift_name("description()")));

/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.9")
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinUnit")))
@interface PrimalSharedKotlinUnit : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinUnit *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)unit __attribute__((swift_name("init()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreSelectInstance")))
@protocol PrimalSharedKotlinx_coroutines_coreSelectInstance
@required
- (void)disposeOnCompletionDisposableHandle:(id<PrimalSharedKotlinx_coroutines_coreDisposableHandle>)disposableHandle __attribute__((swift_name("disposeOnCompletion(disposableHandle:)")));
- (void)selectInRegistrationPhaseInternalResult:(id _Nullable)internalResult __attribute__((swift_name("selectInRegistrationPhase(internalResult:)")));
- (BOOL)trySelectClauseObject:(id)clauseObject result:(id _Nullable)result __attribute__((swift_name("trySelect(clauseObject:result:)")));
@property (readonly) id<PrimalSharedKotlinCoroutineContext> context __attribute__((swift_name("context")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_serialization_jsonJsonPrimitive.Companion")))
@interface PrimalSharedKotlinx_serialization_jsonJsonPrimitiveCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinx_serialization_jsonJsonPrimitiveCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreCompositeEncoder")))
@protocol PrimalSharedKotlinx_serialization_coreCompositeEncoder
@required
- (void)encodeBooleanElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(BOOL)value __attribute__((swift_name("encodeBooleanElement(descriptor:index:value:)")));
- (void)encodeByteElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int8_t)value __attribute__((swift_name("encodeByteElement(descriptor:index:value:)")));
- (void)encodeCharElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(unichar)value __attribute__((swift_name("encodeCharElement(descriptor:index:value:)")));
- (void)encodeDoubleElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(double)value __attribute__((swift_name("encodeDoubleElement(descriptor:index:value:)")));
- (void)encodeFloatElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(float)value __attribute__((swift_name("encodeFloatElement(descriptor:index:value:)")));
- (id<PrimalSharedKotlinx_serialization_coreEncoder>)encodeInlineElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("encodeInlineElement(descriptor:index:)")));
- (void)encodeIntElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int32_t)value __attribute__((swift_name("encodeIntElement(descriptor:index:value:)")));
- (void)encodeLongElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int64_t)value __attribute__((swift_name("encodeLongElement(descriptor:index:value:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)encodeNullableSerializableElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index serializer:(id<PrimalSharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeNullableSerializableElement(descriptor:index:serializer:value:)")));
- (void)encodeSerializableElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index serializer:(id<PrimalSharedKotlinx_serialization_coreSerializationStrategy>)serializer value:(id _Nullable)value __attribute__((swift_name("encodeSerializableElement(descriptor:index:serializer:value:)")));
- (void)encodeShortElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(int16_t)value __attribute__((swift_name("encodeShortElement(descriptor:index:value:)")));
- (void)encodeStringElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index value:(NSString *)value __attribute__((swift_name("encodeStringElement(descriptor:index:value:)")));
- (void)endStructureDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("endStructure(descriptor:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (BOOL)shouldEncodeElementDefaultDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("shouldEncodeElementDefault(descriptor:index:)")));
@property (readonly) PrimalSharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((swift_name("Kotlinx_serialization_coreSerializersModule")))
@interface PrimalSharedKotlinx_serialization_coreSerializersModule : PrimalSharedBase

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (void)dumpToCollector:(id<PrimalSharedKotlinx_serialization_coreSerializersModuleCollector>)collector __attribute__((swift_name("dumpTo(collector:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id<PrimalSharedKotlinx_serialization_coreKSerializer> _Nullable)getContextualKClass:(id<PrimalSharedKotlinKClass>)kClass typeArgumentsSerializers:(NSArray<id<PrimalSharedKotlinx_serialization_coreKSerializer>> *)typeArgumentsSerializers __attribute__((swift_name("getContextual(kClass:typeArgumentsSerializers:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id<PrimalSharedKotlinx_serialization_coreSerializationStrategy> _Nullable)getPolymorphicBaseClass:(id<PrimalSharedKotlinKClass>)baseClass value:(id)value __attribute__((swift_name("getPolymorphic(baseClass:value:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id<PrimalSharedKotlinx_serialization_coreDeserializationStrategy> _Nullable)getPolymorphicBaseClass:(id<PrimalSharedKotlinKClass>)baseClass serializedClassName:(NSString * _Nullable)serializedClassName __attribute__((swift_name("getPolymorphic(baseClass:serializedClassName:)")));
@end

__attribute__((swift_name("KotlinAnnotation")))
@protocol PrimalSharedKotlinAnnotation
@required
@end

__attribute__((swift_name("Kotlinx_serialization_coreCompositeDecoder")))
@protocol PrimalSharedKotlinx_serialization_coreCompositeDecoder
@required
- (BOOL)decodeBooleanElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeBooleanElement(descriptor:index:)")));
- (int8_t)decodeByteElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeByteElement(descriptor:index:)")));
- (unichar)decodeCharElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeCharElement(descriptor:index:)")));
- (int32_t)decodeCollectionSizeDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("decodeCollectionSize(descriptor:)")));
- (double)decodeDoubleElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeDoubleElement(descriptor:index:)")));
- (int32_t)decodeElementIndexDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("decodeElementIndex(descriptor:)")));
- (float)decodeFloatElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeFloatElement(descriptor:index:)")));
- (id<PrimalSharedKotlinx_serialization_coreDecoder>)decodeInlineElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeInlineElement(descriptor:index:)")));
- (int32_t)decodeIntElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeIntElement(descriptor:index:)")));
- (int64_t)decodeLongElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeLongElement(descriptor:index:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (id _Nullable)decodeNullableSerializableElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index deserializer:(id<PrimalSharedKotlinx_serialization_coreDeserializationStrategy>)deserializer previousValue:(id _Nullable)previousValue __attribute__((swift_name("decodeNullableSerializableElement(descriptor:index:deserializer:previousValue:)")));

/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
- (BOOL)decodeSequentially __attribute__((swift_name("decodeSequentially()")));
- (id _Nullable)decodeSerializableElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index deserializer:(id<PrimalSharedKotlinx_serialization_coreDeserializationStrategy>)deserializer previousValue:(id _Nullable)previousValue __attribute__((swift_name("decodeSerializableElement(descriptor:index:deserializer:previousValue:)")));
- (int16_t)decodeShortElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeShortElement(descriptor:index:)")));
- (NSString *)decodeStringElementDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor index:(int32_t)index __attribute__((swift_name("decodeStringElement(descriptor:index:)")));
- (void)endStructureDescriptor:(id<PrimalSharedKotlinx_serialization_coreSerialDescriptor>)descriptor __attribute__((swift_name("endStructure(descriptor:)")));
@property (readonly) PrimalSharedKotlinx_serialization_coreSerializersModule *serializersModule __attribute__((swift_name("serializersModule")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinNothing")))
@interface PrimalSharedKotlinNothing : PrimalSharedBase
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("OkioByteString.Companion")))
@interface PrimalSharedOkioByteStringCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedOkioByteStringCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedOkioByteString *EMPTY __attribute__((swift_name("EMPTY")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedOkioByteString * _Nullable)decodeBase64:(NSString *)receiver __attribute__((swift_name("decodeBase64(_:)")));
- (PrimalSharedOkioByteString *)decodeHex:(NSString *)receiver __attribute__((swift_name("decodeHex(_:)")));
- (PrimalSharedOkioByteString *)encodeUtf8:(NSString *)receiver __attribute__((swift_name("encodeUtf8(_:)")));
- (PrimalSharedOkioByteString *)ofData:(PrimalSharedKotlinByteArray *)data __attribute__((swift_name("of(data:)")));
- (PrimalSharedOkioByteString *)toByteString:(NSData *)receiver __attribute__((swift_name("toByteString(_:)")));
- (PrimalSharedOkioByteString *)toByteString:(PrimalSharedKotlinByteArray *)receiver offset:(int32_t)offset byteCount:(int32_t)byteCount __attribute__((swift_name("toByteString(_:offset:byteCount:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("OkioBuffer.UnsafeCursor")))
@interface PrimalSharedOkioBufferUnsafeCursor : PrimalSharedBase <PrimalSharedOkioCloseable>
@property PrimalSharedOkioBuffer * _Nullable buffer __attribute__((swift_name("buffer")));
@property PrimalSharedKotlinByteArray * _Nullable data __attribute__((swift_name("data")));
@property int32_t end __attribute__((swift_name("end")));
@property int64_t offset __attribute__((swift_name("offset")));
@property BOOL readWrite __attribute__((swift_name("readWrite")));
@property int32_t start __attribute__((swift_name("start")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));

/**
 * @note This method converts instances of IOException to errors.
 * Other uncaught Kotlin exceptions are fatal.
*/
- (BOOL)closeAndReturnError:(NSError * _Nullable * _Nullable)error __attribute__((swift_name("close()")));
- (int64_t)expandBufferMinByteCount:(int32_t)minByteCount __attribute__((swift_name("expandBuffer(minByteCount:)")));
- (int32_t)next __attribute__((swift_name("next()")));
- (int64_t)resizeBufferNewSize:(int64_t)newSize __attribute__((swift_name("resizeBuffer(newSize:)")));
- (int32_t)seekOffset:(int64_t)offset __attribute__((swift_name("seek(offset:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("OkioTimeout.Companion")))
@interface PrimalSharedOkioTimeoutCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedOkioTimeoutCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedOkioTimeout *NONE __attribute__((swift_name("NONE")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
*/
__attribute__((swift_name("KotlinContinuation")))
@protocol PrimalSharedKotlinContinuation
@required
- (void)resumeWithResult:(id _Nullable)result __attribute__((swift_name("resumeWith(result:)")));
@property (readonly) id<PrimalSharedKotlinCoroutineContext> context __attribute__((swift_name("context")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.3")
 *   kotlin.ExperimentalStdlibApi
*/
__attribute__((swift_name("KotlinAbstractCoroutineContextKey")))
@interface PrimalSharedKotlinAbstractCoroutineContextKey<B, E> : PrimalSharedBase <PrimalSharedKotlinCoroutineContextKey>
- (instancetype)initWithBaseKey:(id<PrimalSharedKotlinCoroutineContextKey>)baseKey safeCast:(E _Nullable (^)(id<PrimalSharedKotlinCoroutineContextElement>))safeCast __attribute__((swift_name("init(baseKey:safeCast:)"))) __attribute__((objc_designated_initializer));
@end


/**
 * @note annotations
 *   kotlin.ExperimentalStdlibApi
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_coroutines_coreCoroutineDispatcher.Key")))
@interface PrimalSharedKotlinx_coroutines_coreCoroutineDispatcherKey : PrimalSharedKotlinAbstractCoroutineContextKey<id<PrimalSharedKotlinContinuationInterceptor>, PrimalSharedKotlinx_coroutines_coreCoroutineDispatcher *>
@property (class, readonly, getter=shared) PrimalSharedKotlinx_coroutines_coreCoroutineDispatcherKey *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithBaseKey:(id<PrimalSharedKotlinCoroutineContextKey>)baseKey safeCast:(id<PrimalSharedKotlinCoroutineContextElement> _Nullable (^)(id<PrimalSharedKotlinCoroutineContextElement>))safeCast __attribute__((swift_name("init(baseKey:safeCast:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (instancetype)key __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreProxyConfig")))
@interface PrimalSharedKtor_client_coreProxyConfig : PrimalSharedBase
@property (readonly) PrimalSharedKtor_httpUrl *url __attribute__((swift_name("url")));
- (instancetype)initWithUrl:(PrimalSharedKtor_httpUrl *)url __attribute__((swift_name("init(url:)"))) __attribute__((objc_designated_initializer));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("Ktor_client_coreHttpClientPlugin")))
@protocol PrimalSharedKtor_client_coreHttpClientPlugin
@required
- (void)installPlugin:(id)plugin scope:(PrimalSharedKtor_client_coreHttpClient *)scope __attribute__((swift_name("install(plugin:scope:)")));
- (id)prepareBlock:(void (^)(id))block __attribute__((swift_name("prepare(block:)")));
@property (readonly) PrimalSharedKtor_utilsAttributeKey<id> *key __attribute__((swift_name("key")));
@end

__attribute__((swift_name("Ktor_eventsEventDefinition")))
@interface PrimalSharedKtor_eventsEventDefinition<T> : PrimalSharedBase
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpReceivePipeline.Phases")))
@interface PrimalSharedKtor_client_coreHttpReceivePipelinePhases : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_client_coreHttpReceivePipelinePhases *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *After __attribute__((swift_name("After")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Before __attribute__((swift_name("Before")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *State __attribute__((swift_name("State")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)phases __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpRequestPipeline.Phases")))
@interface PrimalSharedKtor_client_coreHttpRequestPipelinePhases : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_client_coreHttpRequestPipelinePhases *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Before __attribute__((swift_name("Before")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Render __attribute__((swift_name("Render")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Send __attribute__((swift_name("Send")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *State __attribute__((swift_name("State")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Transform __attribute__((swift_name("Transform")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)phases __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("Ktor_httpHttpMessageBuilder")))
@protocol PrimalSharedKtor_httpHttpMessageBuilder
@required
@property (readonly) PrimalSharedKtor_httpHeadersBuilder *headers __attribute__((swift_name("headers")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpRequestBuilder")))
@interface PrimalSharedKtor_client_coreHttpRequestBuilder : PrimalSharedBase <PrimalSharedKtor_httpHttpMessageBuilder>
@property (class, readonly, getter=companion) PrimalSharedKtor_client_coreHttpRequestBuilderCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) id<PrimalSharedKtor_utilsAttributes> attributes __attribute__((swift_name("attributes")));
@property id body __attribute__((swift_name("body")));
@property PrimalSharedKtor_utilsTypeInfo * _Nullable bodyType __attribute__((swift_name("bodyType")));
@property (readonly) id<PrimalSharedKotlinx_coroutines_coreJob> executionContext __attribute__((swift_name("executionContext")));
@property (readonly) PrimalSharedKtor_httpHeadersBuilder *headers __attribute__((swift_name("headers")));
@property PrimalSharedKtor_httpHttpMethod *method __attribute__((swift_name("method")));
@property (readonly) PrimalSharedKtor_httpURLBuilder *url __attribute__((swift_name("url")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (PrimalSharedKtor_client_coreHttpRequestData *)build __attribute__((swift_name("build()")));
- (id _Nullable)getCapabilityOrNullKey:(id<PrimalSharedKtor_client_coreHttpClientEngineCapability>)key __attribute__((swift_name("getCapabilityOrNull(key:)")));
- (void)setAttributesBlock:(void (^)(id<PrimalSharedKtor_utilsAttributes>))block __attribute__((swift_name("setAttributes(block:)")));
- (void)setCapabilityKey:(id<PrimalSharedKtor_client_coreHttpClientEngineCapability>)key capability:(id)capability __attribute__((swift_name("setCapability(key:capability:)")));
- (PrimalSharedKtor_client_coreHttpRequestBuilder *)takeFromBuilder:(PrimalSharedKtor_client_coreHttpRequestBuilder *)builder __attribute__((swift_name("takeFrom(builder:)")));
- (PrimalSharedKtor_client_coreHttpRequestBuilder *)takeFromWithExecutionContextBuilder:(PrimalSharedKtor_client_coreHttpRequestBuilder *)builder __attribute__((swift_name("takeFromWithExecutionContext(builder:)")));
- (void)urlBlock:(void (^)(PrimalSharedKtor_httpURLBuilder *, PrimalSharedKtor_httpURLBuilder *))block __attribute__((swift_name("url(block:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpResponsePipeline.Phases")))
@interface PrimalSharedKtor_client_coreHttpResponsePipelinePhases : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_client_coreHttpResponsePipelinePhases *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *After __attribute__((swift_name("After")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Parse __attribute__((swift_name("Parse")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Receive __attribute__((swift_name("Receive")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *State __attribute__((swift_name("State")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Transform __attribute__((swift_name("Transform")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)phases __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpResponseContainer")))
@interface PrimalSharedKtor_client_coreHttpResponseContainer : PrimalSharedBase
@property (readonly) PrimalSharedKtor_utilsTypeInfo *expectedType __attribute__((swift_name("expectedType")));
@property (readonly) id response __attribute__((swift_name("response")));
- (instancetype)initWithExpectedType:(PrimalSharedKtor_utilsTypeInfo *)expectedType response:(id)response __attribute__((swift_name("init(expectedType:response:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_client_coreHttpResponseContainer *)doCopyExpectedType:(PrimalSharedKtor_utilsTypeInfo *)expectedType response:(id)response __attribute__((swift_name("doCopy(expectedType:response:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpSendPipeline.Phases")))
@interface PrimalSharedKtor_client_coreHttpSendPipelinePhases : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_client_coreHttpSendPipelinePhases *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Before __attribute__((swift_name("Before")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Engine __attribute__((swift_name("Engine")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Monitoring __attribute__((swift_name("Monitoring")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *Receive __attribute__((swift_name("Receive")));
@property (readonly) PrimalSharedKtor_utilsPipelinePhase *State __attribute__((swift_name("State")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)phases __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("Kotlinx_datetimeDateTimeFormat")))
@protocol PrimalSharedKotlinx_datetimeDateTimeFormat
@required
- (NSString *)formatValue:(id _Nullable)value __attribute__((swift_name("format(value:)")));
- (id<PrimalSharedKotlinAppendable>)formatToAppendable:(id<PrimalSharedKotlinAppendable>)appendable value:(id _Nullable)value __attribute__((swift_name("formatTo(appendable:value:)")));
- (id _Nullable)parseInput:(id)input __attribute__((swift_name("parse(input:)")));
- (id _Nullable)parseOrNullInput:(id)input __attribute__((swift_name("parseOrNull(input:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumDecimalMode.Companion")))
@interface PrimalSharedBignumDecimalModeCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedBignumDecimalModeCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedBignumDecimalMode *DEFAULT __attribute__((swift_name("DEFAULT")));
@property (readonly) PrimalSharedBignumDecimalMode *US_CURRENCY __attribute__((swift_name("US_CURRENCY")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("BignumBigNumberUtil")))
@protocol PrimalSharedBignumBigNumberUtil
@required
- (id _Nullable)maxFirst:(id _Nullable)first second:(id _Nullable)second __attribute__((swift_name("max(first:second:)")));
- (id _Nullable)minFirst:(id _Nullable)first second:(id _Nullable)second __attribute__((swift_name("min(first:second:)")));
@end

__attribute__((swift_name("BignumByteArrayDeserializable")))
@protocol PrimalSharedBignumByteArrayDeserializable
@required
- (id<PrimalSharedBignumBigNumber>)fromByteArraySource:(PrimalSharedKotlinByteArray *)source sign:(PrimalSharedBignumSign *)sign __attribute__((swift_name("fromByteArray(source:sign:)")));
- (id<PrimalSharedBignumBigNumber>)fromUByteArraySource:(id)source sign:(PrimalSharedBignumSign *)sign __attribute__((swift_name("fromUByteArray(source:sign:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumBigInteger.Companion")))
@interface PrimalSharedBignumBigIntegerCompanion : PrimalSharedBase <PrimalSharedBignumBigNumberCreator, PrimalSharedBignumBigNumberUtil, PrimalSharedBignumByteArrayDeserializable>
@property (class, readonly, getter=shared) PrimalSharedBignumBigIntegerCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) double LOG_10_OF_2 __attribute__((swift_name("LOG_10_OF_2")));
@property (readonly) PrimalSharedBignumBigInteger *ONE __attribute__((swift_name("ONE")));
@property (readonly) PrimalSharedBignumBigInteger *TEN __attribute__((swift_name("TEN")));
@property (readonly) PrimalSharedBignumBigInteger *TWO __attribute__((swift_name("TWO")));
@property (readonly) PrimalSharedBignumBigInteger *ZERO __attribute__((swift_name("ZERO")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedBignumBigInteger *)createFromWordArrayWordArray:(id)wordArray requestedSign:(PrimalSharedBignumSign *)requestedSign __attribute__((swift_name("createFromWordArray(wordArray:requestedSign:)")));
- (PrimalSharedBignumBigInteger *)fromBigIntegerBigInteger:(PrimalSharedBignumBigInteger *)bigInteger __attribute__((swift_name("fromBigInteger(bigInteger:)")));
- (PrimalSharedBignumBigInteger *)fromByteByte:(int8_t)byte __attribute__((swift_name("fromByte(byte:)")));
- (PrimalSharedBignumBigInteger *)fromByteArraySource:(PrimalSharedKotlinByteArray *)source sign:(PrimalSharedBignumSign *)sign __attribute__((swift_name("fromByteArray(source:sign:)")));
- (PrimalSharedBignumBigInteger *)fromIntInt:(int32_t)int_ __attribute__((swift_name("fromInt(int:)")));
- (PrimalSharedBignumBigInteger *)fromLongLong:(int64_t)long_ __attribute__((swift_name("fromLong(long:)")));
- (PrimalSharedBignumBigInteger *)fromShortShort:(int16_t)short_ __attribute__((swift_name("fromShort(short:)")));
- (PrimalSharedBignumBigInteger *)fromUByteUByte:(uint8_t)uByte __attribute__((swift_name("fromUByte(uByte:)")));
- (PrimalSharedBignumBigInteger *)fromUByteArraySource:(id)source sign:(PrimalSharedBignumSign *)sign __attribute__((swift_name("fromUByteArray(source:sign:)")));
- (PrimalSharedBignumBigInteger *)fromUIntUInt:(uint32_t)uInt __attribute__((swift_name("fromUInt(uInt:)")));
- (PrimalSharedBignumBigInteger *)fromULongULong:(uint64_t)uLong __attribute__((swift_name("fromULong(uLong:)")));
- (PrimalSharedBignumBigInteger *)fromUShortUShort:(uint16_t)uShort __attribute__((swift_name("fromUShort(uShort:)")));
- (PrimalSharedBignumBigInteger *)maxFirst:(PrimalSharedBignumBigInteger *)first second:(PrimalSharedBignumBigInteger *)second __attribute__((swift_name("max(first:second:)")));
- (PrimalSharedBignumBigInteger *)minFirst:(PrimalSharedBignumBigInteger *)first second:(PrimalSharedBignumBigInteger *)second __attribute__((swift_name("min(first:second:)")));
- (PrimalSharedBignumBigInteger *)parseStringString:(NSString *)string base:(int32_t)base __attribute__((swift_name("parseString(string:base:)")));
- (PrimalSharedBignumBigInteger *)tryFromDoubleDouble:(double)double_ exactRequired:(BOOL)exactRequired __attribute__((swift_name("tryFromDouble(double:exactRequired:)")));
- (PrimalSharedBignumBigInteger *)tryFromFloatFloat:(float)float_ exactRequired:(BOOL)exactRequired __attribute__((swift_name("tryFromFloat(float:exactRequired:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumBigInteger.QuotientAndRemainder")))
@interface PrimalSharedBignumBigIntegerQuotientAndRemainder : PrimalSharedBase
@property (readonly) PrimalSharedBignumBigInteger *quotient __attribute__((swift_name("quotient")));
@property (readonly) PrimalSharedBignumBigInteger *remainder __attribute__((swift_name("remainder")));
- (instancetype)initWithQuotient:(PrimalSharedBignumBigInteger *)quotient remainder:(PrimalSharedBignumBigInteger *)remainder __attribute__((swift_name("init(quotient:remainder:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedBignumBigIntegerQuotientAndRemainder *)doCopyQuotient:(PrimalSharedBignumBigInteger *)quotient remainder:(PrimalSharedBignumBigInteger *)remainder __attribute__((swift_name("doCopy(quotient:remainder:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumSign")))
@interface PrimalSharedBignumSign : PrimalSharedKotlinEnum<PrimalSharedBignumSign *>
@property (class, readonly) PrimalSharedBignumSign *positive __attribute__((swift_name("positive")));
@property (class, readonly) PrimalSharedBignumSign *negative __attribute__((swift_name("negative")));
@property (class, readonly) PrimalSharedBignumSign *zero __attribute__((swift_name("zero")));
@property (class, readonly) NSArray<PrimalSharedBignumSign *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedBignumSign *> *)values __attribute__((swift_name("values()")));
- (PrimalSharedBignumSign *)not __attribute__((swift_name("not()")));
- (int32_t)toInt __attribute__((swift_name("toInt()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumBigInteger.BigIntegerRange")))
@interface PrimalSharedBignumBigIntegerBigIntegerRange : PrimalSharedBase <PrimalSharedKotlinClosedRange, PrimalSharedKotlinIterable>
@property (readonly) PrimalSharedBignumBigInteger *endInclusive __attribute__((swift_name("endInclusive")));
@property (readonly) PrimalSharedBignumBigInteger *start __attribute__((swift_name("start")));
- (instancetype)initWithStart:(PrimalSharedBignumBigInteger *)start endInclusive:(PrimalSharedBignumBigInteger *)endInclusive __attribute__((swift_name("init(start:endInclusive:)"))) __attribute__((objc_designated_initializer));
- (id<PrimalSharedKotlinIterator>)iterator __attribute__((swift_name("iterator()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumBigInteger.SqareRootAndRemainder")))
@interface PrimalSharedBignumBigIntegerSqareRootAndRemainder : PrimalSharedBase
@property (readonly) PrimalSharedBignumBigInteger *remainder __attribute__((swift_name("remainder")));
@property (readonly) PrimalSharedBignumBigInteger *squareRoot __attribute__((swift_name("squareRoot")));
- (instancetype)initWithSquareRoot:(PrimalSharedBignumBigInteger *)squareRoot remainder:(PrimalSharedBignumBigInteger *)remainder __attribute__((swift_name("init(squareRoot:remainder:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedBignumBigIntegerSqareRootAndRemainder *)doCopySquareRoot:(PrimalSharedBignumBigInteger *)squareRoot remainder:(PrimalSharedBignumBigInteger *)remainder __attribute__((swift_name("doCopy(squareRoot:remainder:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumModularBigInteger")))
@interface PrimalSharedBignumModularBigInteger : PrimalSharedBase <PrimalSharedBignumBigNumber, PrimalSharedBignumByteArraySerializable>
@property (class, readonly, getter=companion) PrimalSharedBignumModularBigIntegerCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) PrimalSharedBignumBigInteger *modulus __attribute__((swift_name("modulus")));
@property (readonly) PrimalSharedBignumBigInteger *residue __attribute__((swift_name("residue")));
- (PrimalSharedBignumModularBigInteger *)abs __attribute__((swift_name("abs()")));
- (PrimalSharedBignumModularBigInteger *)addOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("add(other:)")));
- (int8_t)byteValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("byteValue(exactRequired:)")));
- (int32_t)compareOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("compare(other:)")));
- (int32_t)compareToOther_:(id)other __attribute__((swift_name("compareTo(other_:)")));
- (PrimalSharedBignumModularBigInteger *)divideOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("divide(other:)")));
- (PrimalSharedKotlinPair<PrimalSharedBignumModularBigInteger *, PrimalSharedBignumModularBigInteger *> *)divideAndRemainderOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("divideAndRemainder(other:)")));
- (PrimalSharedBignumModularQuotientAndRemainder *)divremOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("divrem(other:)")));
- (double)doubleValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("doubleValue(exactRequired:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (float)floatValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("floatValue(exactRequired:)")));
- (id<PrimalSharedBignumBigNumberCreator>)getCreator __attribute__((swift_name("getCreator()")));
- (PrimalSharedBignumModularBigInteger *)getInstance __attribute__((swift_name("getInstance()")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (int32_t)intValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("intValue(exactRequired:)")));
- (PrimalSharedBignumModularBigInteger *)inverse __attribute__((swift_name("inverse()")));
- (BOOL)isZero __attribute__((swift_name("isZero()")));
- (int64_t)longValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("longValue(exactRequired:)")));
- (PrimalSharedBignumModularBigInteger *)multiplyOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("multiply(other:)")));
- (PrimalSharedBignumModularBigInteger *)negate __attribute__((swift_name("negate()")));
- (int64_t)numberOfDecimalDigits __attribute__((swift_name("numberOfDecimalDigits()")));
- (PrimalSharedBignumModularBigInteger *)powExponent__:(PrimalSharedBignumBigInteger *)exponent __attribute__((swift_name("pow(exponent__:)")));
- (PrimalSharedBignumModularBigInteger *)powExponent___:(PrimalSharedBignumModularBigInteger *)exponent __attribute__((swift_name("pow(exponent___:)")));
- (PrimalSharedBignumModularBigInteger *)powExponent:(int32_t)exponent __attribute__((swift_name("pow(exponent:)")));
- (PrimalSharedBignumModularBigInteger *)powExponent_:(int64_t)exponent __attribute__((swift_name("pow(exponent_:)")));
- (PrimalSharedBignumModularBigInteger *)remOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("rem(other:)")));
- (PrimalSharedBignumModularBigInteger *)remainderOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("remainder(other:)")));
- (void)secureOverwrite __attribute__((swift_name("secureOverwrite()")));
- (int16_t)shortValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("shortValue(exactRequired:)")));
- (int32_t)signum __attribute__((swift_name("signum()")));
- (PrimalSharedBignumModularBigInteger *)subtractOther:(PrimalSharedBignumModularBigInteger *)other __attribute__((swift_name("subtract(other:)")));
- (PrimalSharedBignumBigInteger *)toBigInteger __attribute__((swift_name("toBigInteger()")));
- (PrimalSharedKotlinByteArray *)toByteArray __attribute__((swift_name("toByteArray()")));
- (NSString *)description __attribute__((swift_name("description()")));
- (NSString *)toStringBase:(int32_t)base __attribute__((swift_name("toString(base:)")));
- (NSString *)toStringWithModuloBase:(int32_t)base __attribute__((swift_name("toStringWithModulo(base:)")));
- (id)toUByteArray __attribute__((swift_name("toUByteArray()")));
- (uint8_t)ubyteValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ubyteValue(exactRequired:)")));
- (uint32_t)uintValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("uintValue(exactRequired:)")));
- (uint64_t)ulongValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ulongValue(exactRequired:)")));
- (PrimalSharedBignumModularBigInteger *)unaryMinus __attribute__((swift_name("unaryMinus()")));
- (uint16_t)ushortValueExactRequired:(BOOL)exactRequired __attribute__((swift_name("ushortValue(exactRequired:)")));
@end

__attribute__((swift_name("KotlinMapEntry")))
@protocol PrimalSharedKotlinMapEntry
@required
@property (readonly) id _Nullable key __attribute__((swift_name("key")));
@property (readonly) id _Nullable value __attribute__((swift_name("value")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHeaderValueParam")))
@interface PrimalSharedKtor_httpHeaderValueParam : PrimalSharedBase
@property (readonly) BOOL escapeValue __attribute__((swift_name("escapeValue")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
@property (readonly) NSString *value __attribute__((swift_name("value")));
- (instancetype)initWithName:(NSString *)name value:(NSString *)value __attribute__((swift_name("init(name:value:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithName:(NSString *)name value:(NSString *)value escapeValue:(BOOL)escapeValue __attribute__((swift_name("init(name:value:escapeValue:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_httpHeaderValueParam *)doCopyName:(NSString *)name value:(NSString *)value escapeValue:(BOOL)escapeValue __attribute__((swift_name("doCopy(name:value:escapeValue:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHeaderValueWithParameters.Companion")))
@interface PrimalSharedKtor_httpHeaderValueWithParametersCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpHeaderValueWithParametersCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id _Nullable)parseValue:(NSString *)value init:(id _Nullable (^)(NSString *, NSArray<PrimalSharedKtor_httpHeaderValueParam *> *))init __attribute__((swift_name("parse(value:init:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpContentType.Companion")))
@interface PrimalSharedKtor_httpContentTypeCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpContentTypeCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_httpContentType *Any __attribute__((swift_name("Any")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKtor_httpContentType *)parseValue:(NSString *)value __attribute__((swift_name("parse(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHttpStatusCode.Companion")))
@interface PrimalSharedKtor_httpHttpStatusCodeCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpHttpStatusCodeCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Accepted __attribute__((swift_name("Accepted")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *BadGateway __attribute__((swift_name("BadGateway")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *BadRequest __attribute__((swift_name("BadRequest")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Conflict __attribute__((swift_name("Conflict")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Continue __attribute__((swift_name("Continue")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Created __attribute__((swift_name("Created")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *ExpectationFailed __attribute__((swift_name("ExpectationFailed")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *FailedDependency __attribute__((swift_name("FailedDependency")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Forbidden __attribute__((swift_name("Forbidden")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Found __attribute__((swift_name("Found")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *GatewayTimeout __attribute__((swift_name("GatewayTimeout")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Gone __attribute__((swift_name("Gone")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *InsufficientStorage __attribute__((swift_name("InsufficientStorage")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *InternalServerError __attribute__((swift_name("InternalServerError")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *LengthRequired __attribute__((swift_name("LengthRequired")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Locked __attribute__((swift_name("Locked")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *MethodNotAllowed __attribute__((swift_name("MethodNotAllowed")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *MovedPermanently __attribute__((swift_name("MovedPermanently")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *MultiStatus __attribute__((swift_name("MultiStatus")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *MultipleChoices __attribute__((swift_name("MultipleChoices")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *NoContent __attribute__((swift_name("NoContent")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *NonAuthoritativeInformation __attribute__((swift_name("NonAuthoritativeInformation")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *NotAcceptable __attribute__((swift_name("NotAcceptable")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *NotFound __attribute__((swift_name("NotFound")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *NotImplemented __attribute__((swift_name("NotImplemented")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *NotModified __attribute__((swift_name("NotModified")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *OK __attribute__((swift_name("OK")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *PartialContent __attribute__((swift_name("PartialContent")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *PayloadTooLarge __attribute__((swift_name("PayloadTooLarge")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *PaymentRequired __attribute__((swift_name("PaymentRequired")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *PermanentRedirect __attribute__((swift_name("PermanentRedirect")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *PreconditionFailed __attribute__((swift_name("PreconditionFailed")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Processing __attribute__((swift_name("Processing")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *ProxyAuthenticationRequired __attribute__((swift_name("ProxyAuthenticationRequired")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *RequestHeaderFieldTooLarge __attribute__((swift_name("RequestHeaderFieldTooLarge")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *RequestTimeout __attribute__((swift_name("RequestTimeout")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *RequestURITooLong __attribute__((swift_name("RequestURITooLong")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *RequestedRangeNotSatisfiable __attribute__((swift_name("RequestedRangeNotSatisfiable")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *ResetContent __attribute__((swift_name("ResetContent")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *SeeOther __attribute__((swift_name("SeeOther")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *ServiceUnavailable __attribute__((swift_name("ServiceUnavailable")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *SwitchProxy __attribute__((swift_name("SwitchProxy")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *SwitchingProtocols __attribute__((swift_name("SwitchingProtocols")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *TemporaryRedirect __attribute__((swift_name("TemporaryRedirect")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *TooEarly __attribute__((swift_name("TooEarly")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *TooManyRequests __attribute__((swift_name("TooManyRequests")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *Unauthorized __attribute__((swift_name("Unauthorized")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *UnprocessableEntity __attribute__((swift_name("UnprocessableEntity")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *UnsupportedMediaType __attribute__((swift_name("UnsupportedMediaType")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *UpgradeRequired __attribute__((swift_name("UpgradeRequired")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *UseProxy __attribute__((swift_name("UseProxy")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *VariantAlsoNegotiates __attribute__((swift_name("VariantAlsoNegotiates")));
@property (readonly) PrimalSharedKtor_httpHttpStatusCode *VersionNotSupported __attribute__((swift_name("VersionNotSupported")));
@property (readonly) NSArray<PrimalSharedKtor_httpHttpStatusCode *> *allStatusCodes __attribute__((swift_name("allStatusCodes")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKtor_httpHttpStatusCode *)fromValueValue:(int32_t)value __attribute__((swift_name("fromValue(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Kotlinx_io_coreBuffer")))
@interface PrimalSharedKotlinx_io_coreBuffer : PrimalSharedBase <PrimalSharedKotlinx_io_coreSource, PrimalSharedKotlinx_io_coreSink>
@property (readonly) PrimalSharedKotlinx_io_coreBuffer *buffer __attribute__((swift_name("buffer")));
@property (readonly) int64_t size __attribute__((swift_name("size")));
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (void)clear __attribute__((swift_name("clear()")));
- (void)close __attribute__((swift_name("close_()")));
- (PrimalSharedKotlinx_io_coreBuffer *)doCopy __attribute__((swift_name("doCopy()")));
- (void)doCopyToOut:(PrimalSharedKotlinx_io_coreBuffer *)out startIndex:(int64_t)startIndex endIndex:(int64_t)endIndex __attribute__((swift_name("doCopyTo(out:startIndex:endIndex:)")));
- (void)emit_ __attribute__((swift_name("emit_()")));
- (BOOL)exhausted __attribute__((swift_name("exhausted()")));
- (void)flush __attribute__((swift_name("flush_()")));
- (int8_t)getPosition:(int64_t)position __attribute__((swift_name("get(position:)")));

/**
 * @note annotations
 *   kotlinx.io.InternalIoApi
*/
- (void)hintEmit __attribute__((swift_name("hintEmit()")));
- (id<PrimalSharedKotlinx_io_coreSource>)peek __attribute__((swift_name("peek()")));
- (int64_t)readAtMostToSink:(PrimalSharedKotlinx_io_coreBuffer *)sink byteCount:(int64_t)byteCount __attribute__((swift_name("readAtMostTo(sink:byteCount:)")));
- (int32_t)readAtMostToSink:(PrimalSharedKotlinByteArray *)sink startIndex:(int32_t)startIndex endIndex:(int32_t)endIndex __attribute__((swift_name("readAtMostTo(sink:startIndex:endIndex:)")));
- (int8_t)readByte __attribute__((swift_name("readByte()")));
- (int32_t)readInt __attribute__((swift_name("readInt()")));
- (int64_t)readLong __attribute__((swift_name("readLong()")));
- (int16_t)readShort __attribute__((swift_name("readShort()")));
- (void)readToSink:(id<PrimalSharedKotlinx_io_coreRawSink>)sink byteCount:(int64_t)byteCount __attribute__((swift_name("readTo(sink:byteCount:)")));
- (BOOL)requestByteCount:(int64_t)byteCount __attribute__((swift_name("request(byteCount:)")));
- (void)requireByteCount:(int64_t)byteCount __attribute__((swift_name("require(byteCount:)")));
- (void)skipByteCount:(int64_t)byteCount __attribute__((swift_name("skip(byteCount:)")));
- (NSString *)description __attribute__((swift_name("description()")));
- (int64_t)transferFromSource:(id<PrimalSharedKotlinx_io_coreRawSource>)source __attribute__((swift_name("transferFrom(source:)")));
- (int64_t)transferToSink:(id<PrimalSharedKotlinx_io_coreRawSink>)sink __attribute__((swift_name("transferTo(sink:)")));
- (void)writeSource:(PrimalSharedKotlinx_io_coreBuffer *)source byteCount__:(int64_t)byteCount __attribute__((swift_name("write(source:byteCount___:)")));
- (void)writeSource:(id<PrimalSharedKotlinx_io_coreRawSource>)source byteCount_:(int64_t)byteCount __attribute__((swift_name("write(source:byteCount__:)")));
- (void)writeSource:(PrimalSharedKotlinByteArray *)source startIndex:(int32_t)startIndex endIndex:(int32_t)endIndex __attribute__((swift_name("write(source:startIndex:endIndex:)")));
- (void)writeByteByte:(int8_t)byte __attribute__((swift_name("writeByte(byte:)")));
- (void)writeIntInt:(int32_t)int_ __attribute__((swift_name("writeInt(int:)")));
- (void)writeLongLong:(int64_t)long_ __attribute__((swift_name("writeLong(long:)")));
- (void)writeShortShort:(int16_t)short_ __attribute__((swift_name("writeShort(short:)")));

/**
 * @note annotations
 *   kotlinx.io.InternalIoApi
*/
@end


/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
__attribute__((swift_name("Kotlinx_coroutines_coreParentJob")))
@protocol PrimalSharedKotlinx_coroutines_coreParentJob <PrimalSharedKotlinx_coroutines_coreJob>
@required

/**
 * @note annotations
 *   kotlinx.coroutines.InternalCoroutinesApi
*/
- (PrimalSharedKotlinCancellationException *)getChildJobCancellationCause __attribute__((swift_name("getChildJobCancellationCause()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.Serializable
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsGMTDate")))
@interface PrimalSharedKtor_utilsGMTDate : PrimalSharedBase <PrimalSharedKotlinComparable>
@property (class, readonly, getter=companion) PrimalSharedKtor_utilsGMTDateCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t dayOfMonth __attribute__((swift_name("dayOfMonth")));
@property (readonly) PrimalSharedKtor_utilsWeekDay *dayOfWeek __attribute__((swift_name("dayOfWeek")));
@property (readonly) int32_t dayOfYear __attribute__((swift_name("dayOfYear")));
@property (readonly) int32_t hours __attribute__((swift_name("hours")));
@property (readonly) int32_t minutes __attribute__((swift_name("minutes")));
@property (readonly) PrimalSharedKtor_utilsMonth *month __attribute__((swift_name("month")));
@property (readonly) int32_t seconds __attribute__((swift_name("seconds")));
@property (readonly) int64_t timestamp __attribute__((swift_name("timestamp")));
@property (readonly) int32_t year __attribute__((swift_name("year")));
- (instancetype)initWithSeconds:(int32_t)seconds minutes:(int32_t)minutes hours:(int32_t)hours dayOfWeek:(PrimalSharedKtor_utilsWeekDay *)dayOfWeek dayOfMonth:(int32_t)dayOfMonth dayOfYear:(int32_t)dayOfYear month:(PrimalSharedKtor_utilsMonth *)month year:(int32_t)year timestamp:(int64_t)timestamp __attribute__((swift_name("init(seconds:minutes:hours:dayOfWeek:dayOfMonth:dayOfYear:month:year:timestamp:)"))) __attribute__((objc_designated_initializer));
- (int32_t)compareToOther:(PrimalSharedKtor_utilsGMTDate *)other __attribute__((swift_name("compareTo(other:)")));
- (PrimalSharedKtor_utilsGMTDate *)doCopy __attribute__((swift_name("doCopy()")));
- (PrimalSharedKtor_utilsGMTDate *)doCopySeconds:(int32_t)seconds minutes:(int32_t)minutes hours:(int32_t)hours dayOfWeek:(PrimalSharedKtor_utilsWeekDay *)dayOfWeek dayOfMonth:(int32_t)dayOfMonth dayOfYear:(int32_t)dayOfYear month:(PrimalSharedKtor_utilsMonth *)month year:(int32_t)year timestamp:(int64_t)timestamp __attribute__((swift_name("doCopy(seconds:minutes:hours:dayOfWeek:dayOfMonth:dayOfYear:month:year:timestamp:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHttpProtocolVersion")))
@interface PrimalSharedKtor_httpHttpProtocolVersion : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedKtor_httpHttpProtocolVersionCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t major __attribute__((swift_name("major")));
@property (readonly) int32_t minor __attribute__((swift_name("minor")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
- (instancetype)initWithName:(NSString *)name major:(int32_t)major minor:(int32_t)minor __attribute__((swift_name("init(name:major:minor:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_httpHttpProtocolVersion *)doCopyName:(NSString *)name major:(int32_t)major minor:(int32_t)minor __attribute__((swift_name("doCopy(name:major:minor:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinKTypeProjection")))
@interface PrimalSharedKotlinKTypeProjection : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedKotlinKTypeProjectionCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) id<PrimalSharedKotlinKType> _Nullable type __attribute__((swift_name("type")));
@property (readonly) PrimalSharedKotlinKVariance * _Nullable variance __attribute__((swift_name("variance")));
- (instancetype)initWithVariance:(PrimalSharedKotlinKVariance * _Nullable)variance type:(id<PrimalSharedKotlinKType> _Nullable)type __attribute__((swift_name("init(variance:type:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKotlinKTypeProjection *)doCopyVariance:(PrimalSharedKotlinKVariance * _Nullable)variance type:(id<PrimalSharedKotlinKType> _Nullable)type __attribute__((swift_name("doCopy(variance:type:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpUrl.Companion")))
@interface PrimalSharedKtor_httpUrlCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpUrlCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((swift_name("Ktor_httpParameters")))
@protocol PrimalSharedKtor_httpParameters <PrimalSharedKtor_utilsStringValues>
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpURLProtocol")))
@interface PrimalSharedKtor_httpURLProtocol : PrimalSharedBase <PrimalSharedKtor_ioJvmSerializable>
@property (class, readonly, getter=companion) PrimalSharedKtor_httpURLProtocolCompanion *companion __attribute__((swift_name("companion")));
@property (readonly) int32_t defaultPort __attribute__((swift_name("defaultPort")));
@property (readonly) NSString *name __attribute__((swift_name("name")));
- (instancetype)initWithName:(NSString *)name defaultPort:(int32_t)defaultPort __attribute__((swift_name("init(name:defaultPort:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_httpURLProtocol *)doCopyName:(NSString *)name defaultPort:(int32_t)defaultPort __attribute__((swift_name("doCopy(name:defaultPort:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHttpMethod.Companion")))
@interface PrimalSharedKtor_httpHttpMethodCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpHttpMethodCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) NSArray<PrimalSharedKtor_httpHttpMethod *> *DefaultMethods __attribute__((swift_name("DefaultMethods")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *Delete __attribute__((swift_name("Delete")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *Get __attribute__((swift_name("Get")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *Head __attribute__((swift_name("Head")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *Options __attribute__((swift_name("Options")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *Patch __attribute__((swift_name("Patch")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *Post __attribute__((swift_name("Post")));
@property (readonly) PrimalSharedKtor_httpHttpMethod *Put __attribute__((swift_name("Put")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKtor_httpHttpMethod *)parseMethod:(NSString *)method __attribute__((swift_name("parse(method:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Paging_commonLoadStates")))
@interface PrimalSharedPaging_commonLoadStates : PrimalSharedBase
@property (readonly) PrimalSharedPaging_commonLoadState *append __attribute__((swift_name("append")));
@property (readonly) BOOL hasError __attribute__((swift_name("hasError")));
@property (readonly) BOOL isIdle __attribute__((swift_name("isIdle")));
@property (readonly) PrimalSharedPaging_commonLoadState *prepend __attribute__((swift_name("prepend")));
@property (readonly) PrimalSharedPaging_commonLoadState *refresh __attribute__((swift_name("refresh")));
- (instancetype)initWithRefresh:(PrimalSharedPaging_commonLoadState *)refresh prepend:(PrimalSharedPaging_commonLoadState *)prepend append:(PrimalSharedPaging_commonLoadState *)append __attribute__((swift_name("init(refresh:prepend:append:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedPaging_commonLoadStates *)doCopyRefresh:(PrimalSharedPaging_commonLoadState *)refresh prepend:(PrimalSharedPaging_commonLoadState *)prepend append:(PrimalSharedPaging_commonLoadState *)append __attribute__((swift_name("doCopy(refresh:prepend:append:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));

/**
 * @note annotations
 *   androidx.annotation.RestrictTo(value=[Scope.LIBRARY_GROUP])
*/
- (void)forEachOp:(void (^)(PrimalSharedPaging_commonLoadType *, PrimalSharedPaging_commonLoadState *))op __attribute__((swift_name("forEach(op:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinLongProgression.Companion")))
@interface PrimalSharedKotlinLongProgressionCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinLongProgressionCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKotlinLongProgression *)fromClosedRangeRangeStart:(int64_t)rangeStart rangeEnd:(int64_t)rangeEnd step:(int64_t)step __attribute__((swift_name("fromClosedRange(rangeStart:rangeEnd:step:)")));
@end

__attribute__((swift_name("KotlinLongIterator")))
@interface PrimalSharedKotlinLongIterator : PrimalSharedBase <PrimalSharedKotlinIterator>
- (instancetype)init __attribute__((swift_name("init()"))) __attribute__((objc_designated_initializer));
+ (instancetype)new __attribute__((availability(swift, unavailable, message="use object initializers instead")));
- (PrimalSharedLong *)next __attribute__((swift_name("next()")));
- (int64_t)nextLong __attribute__((swift_name("nextLong()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinLongRange.Companion")))
@interface PrimalSharedKotlinLongRangeCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinLongRangeCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKotlinLongRange *EMPTY __attribute__((swift_name("EMPTY")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end


/**
 * @note annotations
 *   kotlinx.serialization.ExperimentalSerializationApi
*/
__attribute__((swift_name("Kotlinx_serialization_coreSerializersModuleCollector")))
@protocol PrimalSharedKotlinx_serialization_coreSerializersModuleCollector
@required
- (void)contextualKClass:(id<PrimalSharedKotlinKClass>)kClass provider:(id<PrimalSharedKotlinx_serialization_coreKSerializer> (^)(NSArray<id<PrimalSharedKotlinx_serialization_coreKSerializer>> *))provider __attribute__((swift_name("contextual(kClass:provider:)")));
- (void)contextualKClass:(id<PrimalSharedKotlinKClass>)kClass serializer:(id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("contextual(kClass:serializer:)")));
- (void)polymorphicBaseClass:(id<PrimalSharedKotlinKClass>)baseClass actualClass:(id<PrimalSharedKotlinKClass>)actualClass actualSerializer:(id<PrimalSharedKotlinx_serialization_coreKSerializer>)actualSerializer __attribute__((swift_name("polymorphic(baseClass:actualClass:actualSerializer:)")));
- (void)polymorphicDefaultBaseClass:(id<PrimalSharedKotlinKClass>)baseClass defaultDeserializerProvider:(id<PrimalSharedKotlinx_serialization_coreDeserializationStrategy> _Nullable (^)(NSString * _Nullable))defaultDeserializerProvider __attribute__((swift_name("polymorphicDefault(baseClass:defaultDeserializerProvider:)"))) __attribute__((deprecated("Deprecated in favor of function with more precise name: polymorphicDefaultDeserializer")));
- (void)polymorphicDefaultDeserializerBaseClass:(id<PrimalSharedKotlinKClass>)baseClass defaultDeserializerProvider:(id<PrimalSharedKotlinx_serialization_coreDeserializationStrategy> _Nullable (^)(NSString * _Nullable))defaultDeserializerProvider __attribute__((swift_name("polymorphicDefaultDeserializer(baseClass:defaultDeserializerProvider:)")));
- (void)polymorphicDefaultSerializerBaseClass:(id<PrimalSharedKotlinKClass>)baseClass defaultSerializerProvider:(id<PrimalSharedKotlinx_serialization_coreSerializationStrategy> _Nullable (^)(id))defaultSerializerProvider __attribute__((swift_name("polymorphicDefaultSerializer(baseClass:defaultSerializerProvider:)")));
@end

__attribute__((swift_name("Ktor_utilsStringValuesBuilder")))
@protocol PrimalSharedKtor_utilsStringValuesBuilder
@required
- (void)appendName:(NSString *)name value:(NSString *)value __attribute__((swift_name("append(name:value:)")));
- (void)appendAllStringValues:(id<PrimalSharedKtor_utilsStringValues>)stringValues __attribute__((swift_name("appendAll(stringValues:)")));
- (void)appendAllName:(NSString *)name values:(id)values __attribute__((swift_name("appendAll(name:values:)")));
- (void)appendMissingStringValues:(id<PrimalSharedKtor_utilsStringValues>)stringValues __attribute__((swift_name("appendMissing(stringValues:)")));
- (void)appendMissingName:(NSString *)name values:(id)values __attribute__((swift_name("appendMissing(name:values:)")));
- (id<PrimalSharedKtor_utilsStringValues>)build __attribute__((swift_name("build()")));
- (void)clear __attribute__((swift_name("clear()")));
- (BOOL)containsName:(NSString *)name __attribute__((swift_name("contains(name:)")));
- (BOOL)containsName:(NSString *)name value:(NSString *)value __attribute__((swift_name("contains(name:value:)")));
- (NSSet<id<PrimalSharedKotlinMapEntry>> *)entries __attribute__((swift_name("entries()")));
- (NSString * _Nullable)getName:(NSString *)name __attribute__((swift_name("get(name:)")));
- (NSArray<NSString *> * _Nullable)getAllName:(NSString *)name __attribute__((swift_name("getAll(name:)")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (NSSet<NSString *> *)names __attribute__((swift_name("names()")));
- (void)removeName:(NSString *)name __attribute__((swift_name("remove(name:)")));
- (BOOL)removeName:(NSString *)name value:(NSString *)value __attribute__((swift_name("remove(name:value:)")));
- (void)removeKeysWithNoEntries __attribute__((swift_name("removeKeysWithNoEntries()")));
- (void)setName:(NSString *)name value:(NSString *)value __attribute__((swift_name("set(name:value:)")));
@property (readonly) BOOL caseInsensitiveName __attribute__((swift_name("caseInsensitiveName")));
@end

__attribute__((swift_name("Ktor_utilsStringValuesBuilderImpl")))
@interface PrimalSharedKtor_utilsStringValuesBuilderImpl : PrimalSharedBase <PrimalSharedKtor_utilsStringValuesBuilder>
@property (readonly) BOOL caseInsensitiveName __attribute__((swift_name("caseInsensitiveName")));
@property (readonly) PrimalSharedMutableDictionary<NSString *, NSMutableArray<NSString *> *> *values __attribute__((swift_name("values")));
- (instancetype)initWithCaseInsensitiveName:(BOOL)caseInsensitiveName size:(int32_t)size __attribute__((swift_name("init(caseInsensitiveName:size:)"))) __attribute__((objc_designated_initializer));
- (void)appendName:(NSString *)name value:(NSString *)value __attribute__((swift_name("append(name:value:)")));
- (void)appendAllStringValues:(id<PrimalSharedKtor_utilsStringValues>)stringValues __attribute__((swift_name("appendAll(stringValues:)")));
- (void)appendAllName:(NSString *)name values:(id)values __attribute__((swift_name("appendAll(name:values:)")));
- (void)appendMissingStringValues:(id<PrimalSharedKtor_utilsStringValues>)stringValues __attribute__((swift_name("appendMissing(stringValues:)")));
- (void)appendMissingName:(NSString *)name values:(id)values __attribute__((swift_name("appendMissing(name:values:)")));
- (id<PrimalSharedKtor_utilsStringValues>)build __attribute__((swift_name("build()")));
- (void)clear __attribute__((swift_name("clear()")));
- (BOOL)containsName:(NSString *)name __attribute__((swift_name("contains(name:)")));
- (BOOL)containsName:(NSString *)name value:(NSString *)value __attribute__((swift_name("contains(name:value:)")));
- (NSSet<id<PrimalSharedKotlinMapEntry>> *)entries __attribute__((swift_name("entries()")));
- (NSString * _Nullable)getName:(NSString *)name __attribute__((swift_name("get(name:)")));
- (NSArray<NSString *> * _Nullable)getAllName:(NSString *)name __attribute__((swift_name("getAll(name:)")));
- (BOOL)isEmpty __attribute__((swift_name("isEmpty()")));
- (NSSet<NSString *> *)names __attribute__((swift_name("names()")));
- (void)removeName:(NSString *)name __attribute__((swift_name("remove(name:)")));
- (BOOL)removeName:(NSString *)name value:(NSString *)value __attribute__((swift_name("remove(name:value:)")));
- (void)removeKeysWithNoEntries __attribute__((swift_name("removeKeysWithNoEntries()")));
- (void)setName:(NSString *)name value:(NSString *)value __attribute__((swift_name("set(name:value:)")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (void)validateNameName:(NSString *)name __attribute__((swift_name("validateName(name:)")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (void)validateValueValue:(NSString *)value __attribute__((swift_name("validateValue(value:)")));

/**
 * @note This property has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHeadersBuilder")))
@interface PrimalSharedKtor_httpHeadersBuilder : PrimalSharedKtor_utilsStringValuesBuilderImpl
- (instancetype)initWithSize:(int32_t)size __attribute__((swift_name("init(size:)"))) __attribute__((objc_designated_initializer));
- (instancetype)initWithCaseInsensitiveName:(BOOL)caseInsensitiveName size:(int32_t)size __attribute__((swift_name("init(caseInsensitiveName:size:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
- (id<PrimalSharedKtor_httpHeaders>)build __attribute__((swift_name("build()")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (void)validateNameName:(NSString *)name __attribute__((swift_name("validateName(name:)")));

/**
 * @note This method has protected visibility in Kotlin source and is intended only for use by subclasses.
*/
- (void)validateValueValue:(NSString *)value __attribute__((swift_name("validateValue(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_client_coreHttpRequestBuilder.Companion")))
@interface PrimalSharedKtor_client_coreHttpRequestBuilderCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_client_coreHttpRequestBuilderCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpURLBuilder")))
@interface PrimalSharedKtor_httpURLBuilder : PrimalSharedBase
@property (class, readonly, getter=companion) PrimalSharedKtor_httpURLBuilderCompanion *companion __attribute__((swift_name("companion")));
@property NSString *encodedFragment __attribute__((swift_name("encodedFragment")));
@property id<PrimalSharedKtor_httpParametersBuilder> encodedParameters __attribute__((swift_name("encodedParameters")));
@property NSString * _Nullable encodedPassword __attribute__((swift_name("encodedPassword")));
@property NSArray<NSString *> *encodedPathSegments __attribute__((swift_name("encodedPathSegments")));
@property NSString * _Nullable encodedUser __attribute__((swift_name("encodedUser")));
@property NSString *fragment __attribute__((swift_name("fragment")));
@property NSString *host __attribute__((swift_name("host")));
@property (readonly) id<PrimalSharedKtor_httpParametersBuilder> parameters __attribute__((swift_name("parameters")));
@property NSString * _Nullable password __attribute__((swift_name("password")));
@property NSArray<NSString *> *pathSegments __attribute__((swift_name("pathSegments")));
@property int32_t port __attribute__((swift_name("port")));
@property PrimalSharedKtor_httpURLProtocol *protocol __attribute__((swift_name("protocol")));
@property PrimalSharedKtor_httpURLProtocol * _Nullable protocolOrNull __attribute__((swift_name("protocolOrNull")));
@property BOOL trailingQuery __attribute__((swift_name("trailingQuery")));
@property NSString * _Nullable user __attribute__((swift_name("user")));
- (instancetype)initWithProtocol:(PrimalSharedKtor_httpURLProtocol * _Nullable)protocol host:(NSString *)host port:(int32_t)port user:(NSString * _Nullable)user password:(NSString * _Nullable)password pathSegments:(NSArray<NSString *> *)pathSegments parameters:(id<PrimalSharedKtor_httpParameters>)parameters fragment:(NSString *)fragment trailingQuery:(BOOL)trailingQuery __attribute__((swift_name("init(protocol:host:port:user:password:pathSegments:parameters:fragment:trailingQuery:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedKtor_httpUrl *)build __attribute__((swift_name("build()")));
- (NSString *)buildString __attribute__((swift_name("buildString()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((swift_name("KotlinAppendable")))
@protocol PrimalSharedKotlinAppendable
@required
- (id<PrimalSharedKotlinAppendable>)appendValue:(unichar)value __attribute__((swift_name("append(value:)")));
- (id<PrimalSharedKotlinAppendable>)appendValue_:(id _Nullable)value __attribute__((swift_name("append(value_:)")));
- (id<PrimalSharedKotlinAppendable>)appendValue:(id _Nullable)value startIndex:(int32_t)startIndex endIndex:(int32_t)endIndex __attribute__((swift_name("append(value:startIndex:endIndex:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumModularBigInteger.Companion")))
@interface PrimalSharedBignumModularBigIntegerCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedBignumModularBigIntegerCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo:(PrimalSharedBignumBigInteger *)modulo __attribute__((swift_name("creatorForModulo(modulo:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo_:(int8_t)modulo __attribute__((swift_name("creatorForModulo(modulo_:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo__:(int32_t)modulo __attribute__((swift_name("creatorForModulo(modulo__:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo___:(int64_t)modulo __attribute__((swift_name("creatorForModulo(modulo___:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo____:(int16_t)modulo __attribute__((swift_name("creatorForModulo(modulo____:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo_____:(uint8_t)modulo __attribute__((swift_name("creatorForModulo(modulo_____:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo______:(uint32_t)modulo __attribute__((swift_name("creatorForModulo(modulo______:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo_______:(uint64_t)modulo __attribute__((swift_name("creatorForModulo(modulo_______:)")));
- (id<PrimalSharedBignumBigNumberCreator>)creatorForModuloModulo________:(uint16_t)modulo __attribute__((swift_name("creatorForModulo(modulo________:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("BignumModularQuotientAndRemainder")))
@interface PrimalSharedBignumModularQuotientAndRemainder : PrimalSharedBase
@property (readonly) PrimalSharedBignumModularBigInteger *quotient __attribute__((swift_name("quotient")));
@property (readonly) PrimalSharedBignumModularBigInteger *remainder __attribute__((swift_name("remainder")));
- (instancetype)initWithQuotient:(PrimalSharedBignumModularBigInteger *)quotient remainder:(PrimalSharedBignumModularBigInteger *)remainder __attribute__((swift_name("init(quotient:remainder:)"))) __attribute__((objc_designated_initializer));
- (PrimalSharedBignumModularQuotientAndRemainder *)doCopyQuotient:(PrimalSharedBignumModularBigInteger *)quotient remainder:(PrimalSharedBignumModularBigInteger *)remainder __attribute__((swift_name("doCopy(quotient:remainder:)")));
- (BOOL)isEqual:(id _Nullable)other __attribute__((swift_name("isEqual(_:)")));
- (NSUInteger)hash __attribute__((swift_name("hash()")));
- (NSString *)description __attribute__((swift_name("description()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsWeekDay")))
@interface PrimalSharedKtor_utilsWeekDay : PrimalSharedKotlinEnum<PrimalSharedKtor_utilsWeekDay *>
@property (class, readonly, getter=companion) PrimalSharedKtor_utilsWeekDayCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) PrimalSharedKtor_utilsWeekDay *monday __attribute__((swift_name("monday")));
@property (class, readonly) PrimalSharedKtor_utilsWeekDay *tuesday __attribute__((swift_name("tuesday")));
@property (class, readonly) PrimalSharedKtor_utilsWeekDay *wednesday __attribute__((swift_name("wednesday")));
@property (class, readonly) PrimalSharedKtor_utilsWeekDay *thursday __attribute__((swift_name("thursday")));
@property (class, readonly) PrimalSharedKtor_utilsWeekDay *friday __attribute__((swift_name("friday")));
@property (class, readonly) PrimalSharedKtor_utilsWeekDay *saturday __attribute__((swift_name("saturday")));
@property (class, readonly) PrimalSharedKtor_utilsWeekDay *sunday __attribute__((swift_name("sunday")));
@property (class, readonly) NSArray<PrimalSharedKtor_utilsWeekDay *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedKtor_utilsWeekDay *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsMonth")))
@interface PrimalSharedKtor_utilsMonth : PrimalSharedKotlinEnum<PrimalSharedKtor_utilsMonth *>
@property (class, readonly, getter=companion) PrimalSharedKtor_utilsMonthCompanion *companion __attribute__((swift_name("companion")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *january __attribute__((swift_name("january")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *february __attribute__((swift_name("february")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *march __attribute__((swift_name("march")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *april __attribute__((swift_name("april")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *may __attribute__((swift_name("may")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *june __attribute__((swift_name("june")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *july __attribute__((swift_name("july")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *august __attribute__((swift_name("august")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *september __attribute__((swift_name("september")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *october __attribute__((swift_name("october")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *november __attribute__((swift_name("november")));
@property (class, readonly) PrimalSharedKtor_utilsMonth *december __attribute__((swift_name("december")));
@property (class, readonly) NSArray<PrimalSharedKtor_utilsMonth *> *entries __attribute__((swift_name("entries")));
@property (readonly) NSString *value __attribute__((swift_name("value")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedKtor_utilsMonth *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsGMTDate.Companion")))
@interface PrimalSharedKtor_utilsGMTDateCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_utilsGMTDateCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_utilsGMTDate *START __attribute__((swift_name("START")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (id<PrimalSharedKotlinx_serialization_coreKSerializer>)serializer __attribute__((swift_name("serializer()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpHttpProtocolVersion.Companion")))
@interface PrimalSharedKtor_httpHttpProtocolVersionCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpHttpProtocolVersionCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_httpHttpProtocolVersion *HTTP_1_0 __attribute__((swift_name("HTTP_1_0")));
@property (readonly) PrimalSharedKtor_httpHttpProtocolVersion *HTTP_1_1 __attribute__((swift_name("HTTP_1_1")));
@property (readonly) PrimalSharedKtor_httpHttpProtocolVersion *HTTP_2_0 __attribute__((swift_name("HTTP_2_0")));
@property (readonly) PrimalSharedKtor_httpHttpProtocolVersion *QUIC __attribute__((swift_name("QUIC")));
@property (readonly) PrimalSharedKtor_httpHttpProtocolVersion *SPDY_3 __attribute__((swift_name("SPDY_3")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKtor_httpHttpProtocolVersion *)fromValueName:(NSString *)name major:(int32_t)major minor:(int32_t)minor __attribute__((swift_name("fromValue(name:major:minor:)")));
- (PrimalSharedKtor_httpHttpProtocolVersion *)parseValue:(id)value __attribute__((swift_name("parse(value:)")));
@end


/**
 * @note annotations
 *   kotlin.SinceKotlin(version="1.1")
*/
__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinKVariance")))
@interface PrimalSharedKotlinKVariance : PrimalSharedKotlinEnum<PrimalSharedKotlinKVariance *>
@property (class, readonly) PrimalSharedKotlinKVariance *invariant __attribute__((swift_name("invariant")));
@property (class, readonly) PrimalSharedKotlinKVariance *in __attribute__((swift_name("in")));
@property (class, readonly) PrimalSharedKotlinKVariance *out __attribute__((swift_name("out")));
@property (class, readonly) NSArray<PrimalSharedKotlinKVariance *> *entries __attribute__((swift_name("entries")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedKotlinKVariance *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("KotlinKTypeProjection.Companion")))
@interface PrimalSharedKotlinKTypeProjectionCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKotlinKTypeProjectionCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKotlinKTypeProjection *STAR __attribute__((swift_name("STAR")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedKotlinKTypeProjection *)contravariantType:(id<PrimalSharedKotlinKType>)type __attribute__((swift_name("contravariant(type:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedKotlinKTypeProjection *)covariantType:(id<PrimalSharedKotlinKType>)type __attribute__((swift_name("covariant(type:)")));

/**
 * @note annotations
 *   kotlin.jvm.JvmStatic
*/
- (PrimalSharedKotlinKTypeProjection *)invariantType:(id<PrimalSharedKotlinKType>)type __attribute__((swift_name("invariant(type:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpURLProtocol.Companion")))
@interface PrimalSharedKtor_httpURLProtocolCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpURLProtocolCompanion *shared __attribute__((swift_name("shared")));
@property (readonly) PrimalSharedKtor_httpURLProtocol *HTTP __attribute__((swift_name("HTTP")));
@property (readonly) PrimalSharedKtor_httpURLProtocol *HTTPS __attribute__((swift_name("HTTPS")));
@property (readonly) PrimalSharedKtor_httpURLProtocol *SOCKS __attribute__((swift_name("SOCKS")));
@property (readonly) PrimalSharedKtor_httpURLProtocol *WS __attribute__((swift_name("WS")));
@property (readonly) PrimalSharedKtor_httpURLProtocol *WSS __attribute__((swift_name("WSS")));
@property (readonly) NSDictionary<NSString *, PrimalSharedKtor_httpURLProtocol *> *byName __attribute__((swift_name("byName")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKtor_httpURLProtocol *)createOrDefaultName:(NSString *)name __attribute__((swift_name("createOrDefault(name:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Paging_commonLoadType")))
@interface PrimalSharedPaging_commonLoadType : PrimalSharedKotlinEnum<PrimalSharedPaging_commonLoadType *>
@property (class, readonly) PrimalSharedPaging_commonLoadType *refresh __attribute__((swift_name("refresh")));
@property (class, readonly) PrimalSharedPaging_commonLoadType *prepend __attribute__((swift_name("prepend")));
@property (class, readonly) PrimalSharedPaging_commonLoadType *append __attribute__((swift_name("append")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
- (instancetype)initWithName:(NSString *)name ordinal:(int32_t)ordinal __attribute__((swift_name("init(name:ordinal:)"))) __attribute__((objc_designated_initializer)) __attribute__((unavailable));
+ (PrimalSharedKotlinArray<PrimalSharedPaging_commonLoadType *> *)values __attribute__((swift_name("values()")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_httpURLBuilder.Companion")))
@interface PrimalSharedKtor_httpURLBuilderCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_httpURLBuilderCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
@end

__attribute__((swift_name("Ktor_httpParametersBuilder")))
@protocol PrimalSharedKtor_httpParametersBuilder <PrimalSharedKtor_utilsStringValuesBuilder>
@required
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsWeekDay.Companion")))
@interface PrimalSharedKtor_utilsWeekDayCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_utilsWeekDayCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKtor_utilsWeekDay *)fromOrdinal:(int32_t)ordinal __attribute__((swift_name("from(ordinal:)")));
- (PrimalSharedKtor_utilsWeekDay *)fromValue:(NSString *)value __attribute__((swift_name("from(value:)")));
@end

__attribute__((objc_subclassing_restricted))
__attribute__((swift_name("Ktor_utilsMonth.Companion")))
@interface PrimalSharedKtor_utilsMonthCompanion : PrimalSharedBase
@property (class, readonly, getter=shared) PrimalSharedKtor_utilsMonthCompanion *shared __attribute__((swift_name("shared")));
+ (instancetype)alloc __attribute__((unavailable));
+ (instancetype)allocWithZone:(struct _NSZone *)zone __attribute__((unavailable));
+ (instancetype)companion __attribute__((swift_name("init()")));
- (PrimalSharedKtor_utilsMonth *)fromOrdinal:(int32_t)ordinal __attribute__((swift_name("from(ordinal:)")));
- (PrimalSharedKtor_utilsMonth *)fromValue:(NSString *)value __attribute__((swift_name("from(value:)")));
@end

#pragma pop_macro("_Nullable_result")
#pragma clang diagnostic pop
NS_ASSUME_NONNULL_END
